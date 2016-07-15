# encoding: utf-8
class Util::Http::Request
  require 'open-uri'
  require 'resolv-replace'
  require 'timeout'

  def self.get(uri, options = {})
    limit    = options[:timeout] || 30
    status   = nil
    body     = ''
    settings = { proxy: Core.proxy(uri) }

    begin
      Timeout.timeout(limit) do
        open(uri, settings) do |f|
          status = f.status[0].to_i
          f.each_line { |line| body += line }
        end
      end
    rescue Timeout::Error
      status = 404
    rescue StandardError
      status = 404
    end

    Util::Http::Response.new(status: status, body: body)
  end
end
