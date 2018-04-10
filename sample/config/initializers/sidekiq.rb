redis_uri = 'redis://localhost:6379/0'
app_name  = 'example'

Sidekiq.configure_server do |config|
  config.redis = { url: redis_uri, namespace: app_name }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_uri, namespace: app_name }
end
