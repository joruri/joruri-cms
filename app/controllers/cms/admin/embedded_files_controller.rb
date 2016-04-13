# encoding: utf-8
class Cms::Admin::EmbeddedFilesController < Cms::Controller::Admin::Base
  def index
    name  = params[:name]
    name += ".#{params[:format]}" if params[:format]

    @file = Cms::EmbeddedFile
            .where(id: params[:id])
            .where(name: name)
            .first
    return http_error(404) unless @file

    path = @file.upload_path
    path = File.dirname(path) + '/thumb.dat' if params[:thumbnail] == true

    send_storage_file path, type: @file.mime_type, filename: @file.name
  end
end
