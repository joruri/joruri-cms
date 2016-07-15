# encoding: utf-8
module Util::Http
  def self.exists?(uri)
    require 'open-uri'
    require 'resolv-replace'
    require 'timeout'

    ok_code = '200 OK'
    
    proxy = Core.proxy(uri)
    proxy = nil if proxy.blank?
    options = {
      proxy: proxy,
      progress_proc: ->(_size) { raise ok_code }
    }

    begin
      Timeout.timeout(2) do
        open(uri, options) { |f| return true if f.status[0].to_i == 200 }
      end
    rescue Timeout::Error
      return false
    rescue => e
      return true if e.to_s == ok_code
    end
    false
  end
end
