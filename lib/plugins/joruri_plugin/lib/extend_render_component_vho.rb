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
      
    end
  end
end
