# encoding: utf-8
class Cms::Admin::EmbeddedFilesController < Cms::Controller::Admin::Base
  
  def index
    name  = params[:name]
    name += ".#{params[:format]}" if params[:format]
    
    item = Cms::EmbeddedFile.new
    item.and :id, params[:id]
    item.and :name, name
    return http_error(404) unless @file = item.find(:first)
    
    path = @file.upload_path
    if params[:thumbnail] == true
      path = File.dirname(path) + "/thumb.dat"
    end
    
    send_storage_file path, :type => @file.mime_type, :filename => @file.name
  end
end