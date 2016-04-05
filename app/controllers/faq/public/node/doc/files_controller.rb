# encoding: utf-8
class Faq::Public::Node::Doc::FilesController < Cms::Controller::Public::Base
  def show
    @content = Page.current_node.content

    @docs = Faq::Doc
            .public_or_preview
            .where(content_id: @content.id)
            .where(name: params[:name])
            .agent_filter(request.mobile)

    if Core.mode == 'preview' && params[:doc_id]
      @docs = @docs.where(id: params[:doc_id])
    end

    @doc = @docs.first
    return http_error(404) unless @doc

    @file = Sys::File.where(parent_unid: @doc.unid)
                     .where(name: "#{params[:file]}.#{params[:format]}")
                     .first
    return http_error(404) unless @file

    if Core.mode == 'preview'
      file_path = @file.upload_path(type: params[:type])
    else ## public
      dir = params[:type] ? "#{params[:type]}/" : ''
      file_path = "#{::File.dirname(@doc.public_path)}/files/#{dir}#{@file.name}"
    end

    return http_error(404) unless ::Storage.exists?(file_path)

    if img = @file.mobile_image(request.mobile, path: file_path)
      return send_data(img.to_blob,
                       type: @file.mime_type,
                       filename: @file.name,
                       disposition: 'inline')
    end

    send_storage_file(file_path, type: @file.mime_type, filename: @file.name)
  end
end
