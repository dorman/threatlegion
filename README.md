# ThreatLegion

An open-source cyber threat analytics platform built with Ruby on Rails for collecting, analyzing, and visualizing cyber threat intelligence.

## Features

- **Threat Intelligence Management**: Track and analyze cyber threats, vulnerabilities, and indicators of compromise (IOCs)
- **Real-time Dashboard**: Visualize threat data with interactive charts and statistics
- **IOC Database**: Store and search IP addresses, domains, file hashes, URLs, and email addresses
- **Threat Feed Integration**: Ingest data from multiple threat intelligence sources
- **MITRE ATT&CK Mapping**: Map threats to MITRE ATT&CK framework tactics and techniques
- **API Access**: RESTful API for programmatic access to threat data
- **User Authentication**: Secure multi-user access with role-based permissions
- **Search & Filter**: Advanced search capabilities across all threat data
- **Export Capabilities**: Export threat data in multiple formats (JSON, CSV, STIX)

## Technology Stack

- **Backend**: Ruby on Rails 7.2
- **Database**: PostgreSQL
- **Frontend**: Hotwire (Turbo + Stimulus), TailwindCSS
- **Background Jobs**: Sidekiq
- **Charts**: Chartkick
- **Authentication**: Devise

## Prerequisites

- Ruby 3.1+
- PostgreSQL 12+
- Redis (for Sidekiq)
- Node.js 18+ and Yarn

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/threatlegion.git
cd threatlegion
```

2. Install dependencies:
```bash
bundle install
yarn install
```

3. Configure database:
```bash
# Edit config/database.yml with your PostgreSQL credentials
cp config/database.yml.example config/database.yml
```

4. Create and setup database:
```bash
rails db:create
rails db:migrate
rails db:seed
```

5. Start the development server:
```bash
bin/dev
```

6. Visit `http://localhost:3000` in your browser

## Default Credentials

After running `rails db:seed`:
- Email: admin@threatlegion.local
- Password: changeme123

**Important**: Change these credentials immediately in production!

## API Usage

### Authentication
```bash
# Get API token (after authentication)
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@threatlegion.local","password":"changeme123"}'
```

### Create Threat
```bash
curl -X POST http://localhost:3000/api/v1/threats \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "threat": {
      "name": "APT29 Campaign",
      "threat_type": "apt",
      "severity": "critical",
      "description": "Advanced persistent threat campaign"
    }
  }'
```

### Query IOCs
```bash
curl http://localhost:3000/api/v1/indicators?type=ip \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Configuration

### Environment Variables

Create a `.env` file in the root directory:

```env
DATABASE_URL=postgresql://user:password@localhost/threatlegion_development
REDIS_URL=redis://localhost:6379/0
SECRET_KEY_BASE=your_secret_key_here

# Optional: Threat Feed API Keys
VIRUSTOTAL_API_KEY=your_key
ABUSEIPDB_API_KEY=your_key
OTXALIENVALUT_API_KEY=your_key
```

### Threat Feed Integration

Configure threat intelligence feeds in `config/threat_feeds.yml`:

```yaml
feeds:
  - name: "Custom Feed"
    url: "https://example.com/feed.json"
    enabled: true
    refresh_interval: 3600
```

## Development

### Running Tests
```bash
rails test
```

### Code Style
```bash
rubocop
```

### Database Console
```bash
rails dbconsole
```

## Deployment

### Docker
```bash
docker-compose up -d
```

### Heroku
```bash
heroku create threatlegion
heroku addons:create heroku-postgresql
heroku addons:create heroku-redis
git push heroku main
heroku run rails db:migrate
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Security

- All passwords are hashed using bcrypt
- API authentication via JWT tokens
- CSRF protection enabled
- SQL injection prevention via ActiveRecord
- XSS protection via Rails sanitization

**Found a security vulnerability?** Please email security@threatlegion.local instead of opening a public issue.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- MITRE ATT&CK Framework
- STIX/TAXII Standards
- Open Threat Exchange (OTX)
- The open-source security community

## Roadmap

- [ ] STIX 2.1 import/export
- [ ] TAXII server support
- [ ] Machine learning threat scoring
- [ ] Automated threat hunting rules
- [ ] Integration with SIEM platforms
- [ ] Mobile application
- [ ] Collaborative threat analysis
- [ ] Threat intelligence sharing network

## Support

- Documentation: https://docs.threatlegion.io
- Issues: https://github.com/yourusername/threatlegion/issues
- Discussions: https://github.com/yourusername/threatlegion/discussions
