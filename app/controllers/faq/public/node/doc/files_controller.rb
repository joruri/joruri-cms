# encoding: utf-8
class Faq::Public::Node::Doc::FilesController < Cms::Controller::Public::Base
  def show
    @content = Page.current_node.content
    
    doc = Faq::Doc.new.public_or_preview
    if Core.mode == 'preview' && params[:doc_id]
      doc.and :id, params[:doc_id]
    end
    doc.and :content_id, @content.id
    doc.and :name, params[:name]
    doc.agent_filter(request.mobile)
    return http_error(404) unless @doc = doc.find(:first)
    
    item = Sys::File.new
    item.and :parent_unid, @doc.unid
    item.and :name, "#{params[:file]}.#{params[:format]}"
    return http_error(404) unless @file = item.find(:first)
    
    if Core.mode == "preview"
      file_path = @file.upload_path(:type => params[:type])
    else ## public
      dir = params[:type] ? "#{params[:type]}/" : ''
      file_path = "#{::File.dirname(@doc.public_path)}/files/#{dir}#{@file.name}"
    end
    
    return http_error(404) unless ::Storage.exists?(file_path)
    
    if img = @file.mobile_image(request.mobile, :path => file_path)
      return send_data(img.to_blob, :type => @file.mime_type, :filename => @file.name, :disposition => 'inline')
    end
    
    send_storage_file file_path, :type => @file.mime_type, :filename => @file.name
  end
end
