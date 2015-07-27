# encoding: utf-8
require 'render_component'

module RenderComponent
  module Components
    module InstanceMethods

      protected
        # Renders the component specified as the response for the current method
        def render_component(options) #:doc:
          component_logging(options) do
            response = component_response(options, true)[2]
            if response.redirect_url
              redirect_to response.redirect_url
            else
              render :text => response.body, :status => response.status
              response
            end
          end
        end
      
      private
        def component_response(options, reuse_response)
          options[:controller] = options[:controller].to_s if options[:controller] && options[:controller].is_a?(Symbol)
          klass = component_class(options)
          component_request  = request_for_component(klass.controller_path, options)
          if jpmobile = options[:jpmobile]
            component_request.env['HTTP_USER_AGENT'] = jpmobile['HTTP_USER_AGENT']
            component_request.env['rack.jpmobile'] = jpmobile['rack.jpmobile']
          end
          # needed ???
          #if reuse_response
            #component_request.env["action_controller.instance"].instance_variable_set :@_response, request.env["action_controller.instance"].instance_variable_get(:@_response)
          #end
          klass.process_with_components(component_request, options[:action], self)
        end
        
      end
  end
end
