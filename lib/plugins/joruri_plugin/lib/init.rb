# encoding: utf-8

def dump(data)
  Sys::Lib::Debugger::Dump.dump_log(data)
end

def error_log(message)
  Rails.logger.error "[ USER ERROR #{Time.now.strftime('%Y-%m-%d %H:%M:%S')} ]: #{message}"
end

class String
  def to_utf8
    require "nkf"
    NKF.nkf('-wxm0', self.to_s)
  end
end

if Joruri.config[:sys_storage].to_s == "db"
  require 'plugins/joruri_plugin/lib/extend_storage_db'
end
