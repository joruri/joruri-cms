# encoding: utf-8
module Sys::Controller::Scaffold::Storage
  include Sys::Lib::File::Transfer

  def do_sync(options={})
    return if !transfer_to_publish?
    begin
      ::Script.run_from_web("cms/storages#transfer", options)
    rescue => e
      ::Script.error "#{e}"
    end
  end

end
