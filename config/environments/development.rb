Joruri::Application.configure do

  config.logger = Logger.new(config.paths["log"].first)
  config.logger.level = Logger::WARN

  config.cache_classes = false
  config.serve_static_assets = false
  config.assets.compress = false
  config.assets.debug = true

  config.whiny_nils = true
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.action_controller.include_all_helpers = false
  config.active_support.deprecation = :log
  config.action_dispatch.best_standards_support = :builtin
  config.active_record.mass_assignment_sanitizer = :strict
  config.active_record.auto_explain_threshold_in_seconds = 0.5

  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.raise_delivery_errors = true

end
