# ThreatLegion Setup Guide

## Prerequisites

Before running ThreatLegion, ensure you have the following installed:

- **Ruby 3.1+** (check with `ruby -v`)
- **PostgreSQL 12+** (check with `psql --version`)
- **Redis** (for Sidekiq background jobs)
- **Node.js 18+** and **Yarn** (check with `node -v` and `yarn -v`)

## Installation Steps

### 1. Install PostgreSQL (if not installed)

**macOS (using Homebrew):**
```bash
brew install postgresql@14
brew services start postgresql@14
```

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install postgresql postgresql-contrib
sudo systemctl start postgresql
```

### 2. Install Redis (if not installed)

**macOS:**
```bash
brew install redis
brew services start redis
```

**Ubuntu/Debian:**
```bash
sudo apt-get install redis-server
sudo systemctl start redis
```

### 3. Install Dependencies

```bash
# Install Ruby gems
bundle install

# Install JavaScript packages
yarn install
```

### 4. Configure Database

The default PostgreSQL configuration should work. If you need custom settings:

```bash
# Edit config/database.yml with your PostgreSQL credentials
# Default assumes PostgreSQL is running on localhost:5432
```

### 5. Create and Setup Database

```bash
# Create the databases
rails db:create

# Run migrations
rails db:migrate

# Seed with sample data
rails db:seed
```

### 6. Start the Application

**Option A: Using bin/dev (recommended for development)**
```bash
bin/dev
```

This starts:
- Rails server on http://localhost:3000
- CSS bundler (TailwindCSS)
- JavaScript bundler (esbuild)

**Option B: Start services separately**
```bash
# Terminal 1: Rails server
rails server

# Terminal 2: CSS bundler
yarn build:css --watch

# Terminal 3: JavaScript bundler
yarn build --watch

# Terminal 4: Sidekiq (for background jobs)
bundle exec sidekiq
```

### 7. Access the Application

Open your browser and navigate to:
```
http://localhost:3000
```

## Default Credentials

After running `rails db:seed`, you can log in with:

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@threatlegion.local | changeme123 |
| Analyst | analyst@threatlegion.local | changeme123 |
| Viewer | viewer@threatlegion.local | changeme123 |

**⚠️ IMPORTANT:** Change these passwords immediately in production!

## Troubleshooting

### PostgreSQL Connection Issues

If you see "connection to server on socket failed":

```bash
# Check if PostgreSQL is running
brew services list  # macOS
sudo systemctl status postgresql  # Linux

# Start PostgreSQL if not running
brew services start postgresql@14  # macOS
sudo systemctl start postgresql  # Linux
```

### Port Already in Use

If port 3000 is already in use:
```bash
# Kill the process using port 3000
lsof -ti:3000 | xargs kill -9

# Or run on a different port
rails server -p 3001
```

### Asset Compilation Issues

If CSS or JavaScript isn't loading:
```bash
# Rebuild assets
yarn build:css
yarn build

# Or use bin/dev which handles this automatically
bin/dev
```

### Redis Connection Issues

If Sidekiq fails to start:
```bash
# Check if Redis is running
redis-cli ping  # Should return "PONG"

# Start Redis if not running
brew services start redis  # macOS
sudo systemctl start redis  # Linux
```

## API Usage

### Get API Token

```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@threatlegion.local","password":"changeme123"}'
```

Response:
```json
{
  "api_token": "your_token_here",
  "user": {
    "id": 1,
    "email": "admin@threatlegion.local",
    "role": "admin"
  }
}
```

### Use API Token

```bash
# List all threats
curl http://localhost:3000/api/v1/threats \
  -H "Authorization: Bearer YOUR_TOKEN"

# Create a new threat
curl -X POST http://localhost:3000/api/v1/threats \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "threat": {
      "name": "New Threat",
      "threat_type": "malware",
      "severity": "high",
      "description": "Description here"
    }
  }'
```

## Development

### Running Tests

```bash
rails test
```

### Code Quality

```bash
# Run RuboCop
rubocop

# Auto-fix issues
rubocop -a
```

### Database Console

```bash
rails dbconsole
```

### Rails Console

```bash
rails console
```

## Production Deployment

### Environment Variables

Create a `.env` file (or set environment variables):

```env
DATABASE_URL=postgresql://user:password@localhost/threatlegion_production
REDIS_URL=redis://localhost:6379/0
SECRET_KEY_BASE=your_secret_key_here
RAILS_ENV=production
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true
```

### Generate Secret Key

```bash
rails secret
```

### Precompile Assets

```bash
RAILS_ENV=production rails assets:precompile
```

### Run Migrations

```bash
RAILS_ENV=production rails db:migrate
```

### Start Production Server

```bash
RAILS_ENV=production rails server
```

## Docker Deployment (Optional)

Create a `docker-compose.yml`:

```yaml
version: '3.8'
services:
  db:
    image: postgres:14
    environment:
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data
  
  redis:
    image: redis:7-alpine
  
  web:
    build: .
    command: bundle exec rails server -b 0.0.0.0
    volumes:
      - .:/app
    ports:
      - "3000:3000"
    depends_on:
      - db
      - redis
    environment:
      DATABASE_URL: postgresql://postgres:password@db/threatlegion_production
      REDIS_URL: redis://redis:6379/0

volumes:
  postgres_data:
```

Then run:
```bash
docker-compose up
```

## Support

For issues and questions:
- GitHub Issues: https://github.com/yourusername/threatlegion/issues
- Documentation: See README.md

## Next Steps

1. Change default passwords
2. Configure threat feed API keys (optional)
3. Set up SSL/TLS for production
4. Configure backup strategy
5. Set up monitoring and logging
6. Review security settings
