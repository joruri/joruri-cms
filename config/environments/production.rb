Joruri::Application.configure do
  # config.threadsafe!

  config.logger = Logger.new(config.paths["log"].first)
  config.logger.level = Logger::WARN
  
  config.cache_classes = true
  # config.cache_store = :mem_cache_store
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  
  config.serve_static_assets = true
  config.assets.compress = true
  config.assets.compile = false
  config.assets.digest = true
  # config.assets.manifest = YOUR_PATH
  # config.action_controller.asset_host = "http://assets.example.com"
  # config.assets.precompile += %w( search.js )

  # config.force_ssl = true

  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.raise_delivery_errors = false

end
