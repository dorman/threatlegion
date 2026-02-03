namespace :threat_digest do
  desc "Send daily threat digest email"
  task send: :environment do
    puts "Sending daily threat digest..."
    DailyThreatDigestJob.perform_now
    puts "Daily threat digest sent successfully!"
  end
end
