require 'sidekiq'
require 'sidekiq-cron'

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0') }
  
  # Schedule daily threat digest job
  Sidekiq::Cron::Job.create(
    name: 'Daily Threat Digest',
    cron: '0 8 * * *', # Run daily at 8:00 AM
    class: 'DailyThreatDigestJob'
  )
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0') }
end
