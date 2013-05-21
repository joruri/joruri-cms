# encoding: utf-8
# hpricot patch for v0.8.2 .. 0.8.4
require 'hpricot'

module Hpricot
  module Node
    def html_quote(str)
      #s = "\"" + str.gsub('"', '\\"') + "\""
      s = "\"" + str.force_encoding('utf-8').gsub('"', '\\"') + "\""
    end
  end

  Text.class_eval do
    def output(out, opts = {})
      out <<
        if_output(opts) do
          #content.to_s
          content.to_s.force_encoding('utf-8')
        end
    end
  end
end
