# encoding: utf-8
class Cms::Public::EmbeddedFilesController < Cms::Controller::Public::Base
  
  def index
    @skip_layout = true
    
    paths = params[:path].to_s.split("/")
    name  = paths.last
    type  = paths.size == 3 ? paths[1] : nil
    return http_error(404) if paths.size != 2 && paths.size != 3
    return http_error(404) if paths[0] !~ /^[0-9]+$/
    
    item = Cms::EmbeddedFile.new.public
    item.and :id, paths[0].gsub(/.$/, '') 
    item.and :site_id, Page.site.id 
    item.and :name, name
    return http_error(404) unless item = item.find(:first, :order => :id)
    
    path = item.public_path
    path = ::File.dirname(path) + "/#{type}/#{name}" if type
    return http_error(404) unless ::Storage.exists?(path)
    
    return send_storage_file(path, :type => item.mime_type, :filename => item.name) if type
    
    if img = item.mobile_image(request.mobile, :path => item.public_path)
      return send_data(img.to_blob, :type => item.mime_type, :filename => item.name, :disposition => 'inline')
    end
    
    send_storage_file path, :type => item.mime_type, :filename => item.name
  end
end