# encoding: utf-8
module Rack
  module Session
    module Abstract
      class OptionsHash < Hash #:nodoc:
        def initialize(by, env, default_options)
          ::Core.initialize(env)
          ::Core.recognize_path(env["PATH_INFO"])
          env["PATH_INFO"] = ::Core.internal_uri
          
          @by = by
          @env = env
          @session_id_loaded = false
          merge!(default_options)
        end
      end
    end
  end
end
