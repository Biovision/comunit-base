redis_uri = 'redis://localhost:6379/0'
app_name  = 'example'

Sidekiq.configure_server do |config|
  config.redis = { url: redis_uri, namespace: app_name }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_uri, namespace: app_name }
end

Rails.application.configure do
  config.time_zone = 'Moscow'

  config.i18n.enforce_available_locales = true
  config.i18n.load_path                 += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
  config.i18n.default_locale            = :ru

  config.active_job.queue_adapter = :sidekiq

  config.exceptions_app = self.routes

  config.news_index_name  = "#{app_name}_news"
  config.post_index_name  = "#{app_name}_posts"
  config.entry_index_name = "#{app_name}_entries"
end
