# Daily Threat Digest Email Setup

This document explains how to set up and configure the daily email digest system that sends top malicious URLs from abuse.ch.

## Overview

The daily digest system automatically sends an email every day at 8:00 AM with the top 20 malicious URLs retrieved from abuse.ch's URLhaus feed.

## Components

1. **ThreatDigestMailer** (`app/mailers/threat_digest_mailer.rb`) - Handles email composition
2. **DailyThreatDigestJob** (`app/jobs/daily_threat_digest_job.rb`) - Fetches URLs and sends email
3. **Email Templates** - HTML and text versions in `app/views/threat_digest_mailer/`
4. **Scheduled Job** - Configured in `config/initializers/sidekiq.rb` using sidekiq-cron

## Setup Instructions

### 1. Install Dependencies

```bash
bundle install
```

This will install the `sidekiq-cron` gem for scheduled jobs.

### 2. Configure Email Settings

#### Development Environment

For development, you can use a service like [Mailtrap](https://mailtrap.io/) or configure SMTP:

Edit `config/environments/development.rb`:

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: 'smtp.mailtrap.io',
  port: 2525,
  domain: 'threatlegion.local',
  user_name: ENV['SMTP_USERNAME'],
  password: ENV['SMTP_PASSWORD'],
  authentication: :plain
}
```

#### Production Environment

Edit `config/environments/production.rb`:

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: ENV['SMTP_ADDRESS'],
  port: ENV['SMTP_PORT'] || 587,
  domain: ENV['SMTP_DOMAIN'],
  user_name: ENV['SMTP_USERNAME'],
  password: ENV['SMTP_PASSWORD'],
  authentication: :plain,
  enable_starttls_auto: true
}
```

### 3. Set Environment Variables

Add to your `.env` file or environment:

```bash
# Email recipient (optional - defaults to first admin user)
THREAT_DIGEST_EMAIL=your-email@example.com

# Mailer from address
MAILER_FROM_EMAIL=noreply@threatlegion.local

# SMTP Configuration (for production)
SMTP_ADDRESS=smtp.gmail.com
SMTP_PORT=587
SMTP_DOMAIN=threatlegion.local
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password

# Redis URL (for Sidekiq)
REDIS_URL=redis://localhost:6379/0
```

### 4. Start Sidekiq

The scheduled job requires Sidekiq to be running:

```bash
# In a separate terminal
bundle exec sidekiq
```

Or use a process manager like `foreman` or `systemd` in production.

### 5. Test the Email

#### Manual Test via Rake Task

```bash
rails threat_digest:send
```

#### Manual Test via Rails Console

```ruby
DailyThreatDigestJob.perform_now
```

#### Test Email Delivery in Development

```ruby
# In Rails console
ThreatDigestMailer.daily_digest('test@example.com', [
  {
    url: 'http://example.com/malicious',
    url_status: 'online',
    threat: 'malware',
    host: 'example.com',
    date_added: '2024-01-01',
    reporter: 'abuse.ch',
    tags: ['malware', 'phishing'],
    urlhaus_link: 'https://urlhaus.abuse.ch/url/12345/'
  }
]).deliver_now
```

## Scheduling

The job is scheduled to run daily at 8:00 AM using sidekiq-cron. The schedule is defined in `config/initializers/sidekiq.rb`:

```ruby
Sidekiq::Cron::Job.create(
  name: 'Daily Threat Digest',
  cron: '0 8 * * *', # Run daily at 8:00 AM
  class: 'DailyThreatDigestJob'
)
```

### Change Schedule

To change the schedule, modify the cron expression:
- `'0 8 * * *'` - Daily at 8:00 AM
- `'0 9 * * 1'` - Every Monday at 9:00 AM
- `'0 */6 * * *'` - Every 6 hours
- `'0 0 * * *'` - Daily at midnight

See [cron expression format](https://crontab.guru/) for more options.

## Email Content

The email includes:
- **Statistics**: Total URLs, online/offline counts
- **Top 20 Malicious URLs** with:
  - URL and status (online/offline)
  - Threat type
  - Host information
  - Date added
  - Reporter
  - Tags
  - Link to URLhaus

## Troubleshooting

### Email Not Sending

1. **Check Sidekiq is running**: `ps aux | grep sidekiq`
2. **Check Redis is running**: `redis-cli ping`
3. **Check logs**: `tail -f log/development.log` or `tail -f log/production.log`
4. **Verify SMTP settings**: Test with `rails console` and manual mailer call

### Job Not Scheduled

1. **Check Sidekiq initializer**: Ensure `config/initializers/sidekiq.rb` is loaded
2. **Restart Sidekiq**: After changing the schedule, restart Sidekiq
3. **Check Sidekiq web UI**: Visit `/sidekiq` (if configured) to see scheduled jobs

### SMTP Errors

1. **Verify credentials**: Check SMTP username/password
2. **Check firewall**: Ensure port 587/465 is open
3. **Use app passwords**: For Gmail, use app-specific passwords, not your regular password
4. **Check TLS/SSL**: Ensure `enable_starttls_auto: true` is set

## Production Deployment

1. **Set environment variables** in your hosting platform
2. **Configure Sidekiq as a service** (systemd, supervisor, etc.)
3. **Set up monitoring** for job failures
4. **Configure email delivery** using a reliable SMTP service (SendGrid, AWS SES, etc.)

## Customization

### Change Number of URLs

Edit `app/jobs/daily_threat_digest_job.rb`:

```ruby
urls = result[:urls].first(20) # Change 20 to desired number
```

### Change Recipient Logic

Edit `app/jobs/daily_threat_digest_job.rb`:

```ruby
def find_admin_email
  # Custom logic to find recipient(s)
  User.where(role: 'admin').pluck(:email)
end
```

### Customize Email Template

Edit `app/views/threat_digest_mailer/daily_digest.html.erb` and `.text.erb`
