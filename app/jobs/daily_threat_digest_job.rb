class DailyThreatDigestJob < ApplicationJob
  queue_as :default

  def perform
    # Get recipient email from environment variable or default to configured email
    recipient_email = ENV['THREAT_DIGEST_EMAIL'].presence || 'edorman@protonmail.com'
    
    return if recipient_email.blank?
    
    # Fetch top malicious URLs from abuse.ch
    service = AbuseChService.new
    result = service.get_recent_urls(limit: 50) # Get top 50 URLs
    
    if result[:success] && result[:urls].present?
      urls = result[:urls].first(20) # Send top 20 in email
      ThreatDigestMailer.daily_digest(recipient_email, urls).deliver_now
      Rails.logger.info "Daily threat digest sent to #{recipient_email} with #{urls.count} URLs"
    else
      Rails.logger.error "Failed to fetch URLs for daily digest: #{result[:error]}"
    end
  rescue StandardError => e
    Rails.logger.error "Error sending daily threat digest: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end

  private

  def find_admin_email
    # Find first admin user's email, or return nil
    admin = User.where(role: 'admin').first
    admin&.email
  end
end
