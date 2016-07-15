# refer to render_component_vho gem
module RenderComponent
  module HelperMethods
    def render_component(options)
      controller.render_component_into_view(options)
    end

    def render_component_into_view(options)
      controller.render_component_into_view(options)
    end
  end

  module InstanceMethods
    def render_component(options)
      response = component_response(options)[2]
      if response.redirect_url
        redirect_to response.redirect_url
      else
        render text: response.body, status: response.status
        response
      end
    end

    def render_component_into_view(options)
      response = component_response(options)[2]
      response.body.html_safe
    end

    private

    def component_response(options)
      controller = "#{options[:controller].to_s.camelize}Controller".constantize.new
      component_request = request_for_component(controller.controller_path, options)
      status, headers, body = controller.dispatch(options[:action], component_request)
      [status, headers, controller.response]
    end

    def request_for_component(_controller_path, options)
      component_params = options.delete(:params)
      jpmobile_params = options.delete(:jpmobile)
      options.merge!(component_params) if component_params

      request_params = options.symbolize_keys
      request_env = request.env.dup
      request_env['action_dispatch.request.symbolized_path_parameters'] = request_params
      request_env['action_dispatch.request.parameters'] = request_params.with_indifferent_access
      request_env['action_dispatch.request.path_parameters'] = request_params.slice(:controller, :action)
      if jpmobile_params
        request_env['HTTP_USER_AGENT'] = jpmobile_params['HTTP_USER_AGENT']
        request_env['rack.jpmobile'] = jpmobile_params['rack.jpmobile']
      end
      ActionDispatch::Request.new(request_env)
    end
  end
end

ActionController::Base.include RenderComponent::InstanceMethods
ActionController::Base.helper RenderComponent::HelperMethods
