puts "Seeding ThreatLegion database..."

admin = User.find_or_create_by!(email: "admin@threatlegion.local") do |user|
  user.password = "changeme123"
  user.password_confirmation = "changeme123"
  user.role = "admin"
end
puts "✓ Created admin user: #{admin.email}"

analyst = User.find_or_create_by!(email: "analyst@threatlegion.local") do |user|
  user.password = "changeme123"
  user.password_confirmation = "changeme123"
  user.role = "analyst"
end
puts "✓ Created analyst user: #{analyst.email}"

viewer = User.find_or_create_by!(email: "viewer@threatlegion.local") do |user|
  user.password = "changeme123"
  user.password_confirmation = "changeme123"
  user.role = "viewer"
end
puts "✓ Created viewer user: #{viewer.email}"

threat1 = Threat.find_or_create_by!(name: "APT29 Phishing Campaign") do |t|
  t.threat_type = "apt"
  t.severity = "critical"
  t.status = "active"
  t.description = "Advanced persistent threat group targeting government and healthcare organizations with sophisticated phishing campaigns."
  t.confidence_score = 95
  t.first_seen = 30.days.ago
  t.last_seen = 1.day.ago
  t.user = admin
end
puts "✓ Created threat: #{threat1.name}"

Indicator.find_or_create_by!(value: "192.168.100.50") do |i|
  i.indicator_type = "ip"
  i.threat = threat1
  i.confidence = 90
  i.source = "Internal Analysis"
  i.first_seen = 25.days.ago
  i.last_seen = 1.day.ago
  i.tags = ["c2", "malicious"]
end

Indicator.find_or_create_by!(value: "malicious-domain.evil") do |i|
  i.indicator_type = "domain"
  i.threat = threat1
  i.confidence = 85
  i.source = "Threat Feed"
  i.first_seen = 20.days.ago
  i.last_seen = 2.days.ago
  i.tags = ["phishing", "c2"]
end

Indicator.find_or_create_by!(value: "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6") do |i|
  i.indicator_type = "hash"
  i.threat = threat1
  i.confidence = 95
  i.source = "VirusTotal"
  i.first_seen = 30.days.ago
  i.last_seen = 5.days.ago
  i.tags = ["malware", "trojan"]
end
puts "✓ Created indicators for #{threat1.name}"

MitreAttack.find_or_create_by!(technique_id: "T1566.001") do |m|
  m.threat = threat1
  m.tactic = "Initial Access"
  m.technique = "Spearphishing Attachment"
  m.description = "Adversaries send spearphishing emails with malicious attachments"
end

MitreAttack.find_or_create_by!(technique_id: "T1059.001") do |m|
  m.threat = threat1
  m.tactic = "Execution"
  m.technique = "PowerShell"
  m.description = "Adversaries abuse PowerShell commands and scripts for execution"
end
puts "✓ Created MITRE ATT&CK mappings for #{threat1.name}"

threat2 = Threat.find_or_create_by!(name: "Ransomware Attack - LockBit 3.0") do |t|
  t.threat_type = "ransomware"
  t.severity = "high"
  t.status = "investigating"
  t.description = "LockBit 3.0 ransomware variant targeting enterprise networks with double extortion tactics."
  t.confidence_score = 88
  t.first_seen = 15.days.ago
  t.last_seen = 3.days.ago
  t.user = analyst
end
puts "✓ Created threat: #{threat2.name}"

Indicator.find_or_create_by!(value: "10.0.0.100") do |i|
  i.indicator_type = "ip"
  i.threat = threat2
  i.confidence = 80
  i.source = "Network Logs"
  i.first_seen = 15.days.ago
  i.last_seen = 3.days.ago
  i.tags = ["ransomware", "c2"]
end

threat3 = Threat.find_or_create_by!(name: "SQL Injection Attempts") do |t|
  t.threat_type = "exploit"
  t.severity = "medium"
  t.status = "mitigated"
  t.description = "Multiple SQL injection attempts detected against web application endpoints."
  t.confidence_score = 75
  t.first_seen = 7.days.ago
  t.last_seen = 1.day.ago
  t.user = analyst
end
puts "✓ Created threat: #{threat3.name}"

threat4 = Threat.find_or_create_by!(name: "DDoS Botnet Activity") do |t|
  t.threat_type = "ddos"
  t.severity = "high"
  t.status = "active"
  t.description = "Distributed denial of service attacks originating from compromised IoT devices."
  t.confidence_score = 82
  t.first_seen = 5.days.ago
  t.last_seen = Time.current
  t.user = admin
end
puts "✓ Created threat: #{threat4.name}"

Vulnerability.find_or_create_by!(cve_id: "CVE-2024-1234") do |v|
  v.cvss_score = 9.8
  v.description = "Critical remote code execution vulnerability in widely-used web framework"
  v.published_date = 10.days.ago
  v.affected_products = "WebFramework 3.x, WebFramework 4.0-4.2"
  v.threat = threat3
end

Vulnerability.find_or_create_by!(cve_id: "CVE-2024-5678") do |v|
  v.cvss_score = 7.5
  v.description = "High severity authentication bypass in enterprise application"
  v.published_date = 20.days.ago
  v.affected_products = "EnterpriseApp 2.x"
  v.threat = threat3
end
puts "✓ Created vulnerabilities"

10.times do |i|
  Indicator.find_or_create_by!(value: "malicious-#{i}.example.com") do |ind|
    ind.indicator_type = "domain"
    ind.confidence = rand(60..95)
    ind.source = "Automated Feed"
    ind.first_seen = rand(1..30).days.ago
    ind.last_seen = rand(1..5).days.ago
    ind.tags = ["automated", "suspicious"]
  end
end
puts "✓ Created additional indicators"

puts "\n" + "="*50
puts "Database seeding completed!"
puts "="*50
puts "\nDefault credentials:"
puts "  Admin:   admin@threatlegion.local / changeme123"
puts "  Analyst: analyst@threatlegion.local / changeme123"
puts "  Viewer:  viewer@threatlegion.local / changeme123"
puts "\n⚠️  IMPORTANT: Change these passwords in production!"
puts "="*50
