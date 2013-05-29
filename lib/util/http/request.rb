# encoding: utf-8
class Util::Http::Request
  require 'open-uri'
  require "resolv-replace"
  require 'timeout'
  
  def self.get(uri, options = {})
    limit    = options[:timeout] || 30
    status   = nil
    body     = ''
    settings = { :proxy => Core.proxy(uri) }
    
    begin
      timeout(limit) do
        open(uri, settings) do |f|
          status = f.status[0].to_i
          f.each_line {|line| body += line}
        end
      end
    rescue TimeoutError
      status = 404
    rescue Exception
      status = 404
    end
    
    return Util::Http::Response.new({:status => status, :body => body})
  end
  
#  require 'uri'
#  require "net/http"
#  
#  def self.head(uri, options = {})
#    uri = uri.gsub(/#.*/, '')
#    
#    header = options[:header] || {}
#    header['User-Agent'] ||= "Mozilla/5.0 (Joruri/#{Joruri.version})"
#    
#    parsed = URI.parse(uri)
#    host   = parsed.host
#    path   = parsed.path.to_s == '' ? '/' : parsed.path
#    port   = parsed.port || (parsed.scheme == 'https' ? 443 : 80)
#    path  += '?' + parsed.query if parsed.query
#    
#    proxy = (Core.proxy.class == String) ? URI.parse(Core.proxy) : URI.parse("")
#    http  = Net::HTTP.new(host, port, proxy.host, proxy.port)
#    http.use_ssl = true if parsed.scheme == 'https'
#    http.open_timeout = 5
#    http.read_timeout = 5
#    http.start() do
#      return http.head(path, header)
#    end
#    nil
#  rescue => e
#    nil
#  end
#  
#  def self.post(uri, body, options = {})
#    uri = uri.gsub(/#.*/, '')
#    
#    header = options[:header] || {}
#    header['User-Agent'] ||= "Mozilla/5.0 (Joruri/#{Joruri.version})"
#    
#    parsed = URI.parse(uri)
#    host   = parsed.host
#    path   = parsed.path.to_s == '' ? '/' : parsed.path
#    port   = parsed.port || (parsed.scheme == 'https' ? 443 : 80)
#    path  += '?' + parsed.query if parsed.query
#    
#    proxy = (Core.proxy.class == String) ? URI.parse(Core.proxy) : URI.parse("")
#    http  = Net::HTTP.new(host, port, proxy.host, proxy.port)
#    http.use_ssl = true if parsed.scheme == 'https'
#    http.open_timeout = 5
#    http.read_timeout = 5
#    http.start() do
#      if body.class == Hash
#        body = Util::Http::QueryString.build_query(body).gsub(/^\?/, '')
#      end
#      return http.post(path, body, header)
#    end
#    nil
#  rescue => e
#    nil
#  end

end