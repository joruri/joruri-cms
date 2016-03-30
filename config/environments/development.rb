Joruri::Application.configure do

  config.logger = Logger.new(config.paths["log"].first)
  config.logger.level = Logger::DEBUG

  config.cache_classes = false
  config.eager_load = false
  config.serve_static_files = false
  config.assets.debug = true
  config.assets.digest = true
  config.assets.raise_runtime_errors = true
  
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.action_controller.include_all_helpers = false
  config.active_support.deprecation = :log
  config.action_dispatch.best_standards_support = :builtin

  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.raise_delivery_errors = true

end
