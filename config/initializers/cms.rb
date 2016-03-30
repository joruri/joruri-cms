module Cms
  module Rack
    class Router
      def initialize(app)
        @app = app
      end
    
      def call(env)
        Core.initialize(env)
        Core.recognize_path(env['PATH_INFO'])
        env['PATH_INFO'] = Core.internal_uri
    
        @app.call(env)
      end
    end
  end
end

Rails.application.config.middleware.use Cms::Rack::Router
