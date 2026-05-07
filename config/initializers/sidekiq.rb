redis_url = "redis://#{ENV.fetch('REDIS_HOST', '127.0.0.1')}:#{ENV.fetch('REDIS_PORT', '6379')}/#{ENV.fetch('REDIS_DB', '1')}"

Sidekiq.configure_server { |c| c.redis = { url: redis_url } }
Sidekiq.configure_client { |c| c.redis = { url: redis_url } }
