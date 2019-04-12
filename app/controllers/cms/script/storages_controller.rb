# encoding: utf-8
require 'digest/md5'
class Cms::Script::StoragesController < Cms::Controller::Script::Publication
  include Sys::Lib::File::Transfer

  def transfer
    options = Script.options
    transfer_files(options) if transfer_to_publish?
    Script.success
    render text: 'OK'
  end

end
