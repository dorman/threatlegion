class ThreatDigestMailer < ApplicationMailer
  # Send daily digest of top malicious URLs from abuse.ch
  def daily_digest(email, urls)
    @urls = urls
    @date = Date.current.strftime("%B %d, %Y")
    @total_urls = urls.count
    @online_urls = urls.count { |u| u[:url_status] == 'online' }
    
    mail(
      to: email,
      subject: "ThreatLegion Daily Digest - #{@total_urls} Malicious URLs (#{@date})"
    )
  end
end
