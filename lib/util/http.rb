# encoding: utf-8
module Util::Http
  
  def self.exists?(uri)
    require 'open-uri'
    require "resolv-replace"
    require 'timeout'
    
    ok_code = '200 OK'
    options = {
      :proxy => Core.proxy(uri),
#      :progress_proc => lambda {|size| raise ok_code },
      'User-Agent' => "CMS/#{Joruri.version}"
    }
    
    begin
      timeout(2) do
        open(uri, options) {|f| return true if f.status[0].to_i == 200 }
      end
    rescue TimeoutError
      return false
    rescue => e
      return true if e.to_s == ok_code
    end
    return false
  end
  
end
