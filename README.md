# Unending - Real-time HTTP Request Catcher & Mock Server

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ruby Version](https://img.shields.io/badge/ruby-4.0.3-red.svg)](https://www.ruby-lang.org/)
[![Rails Version](https://img.shields.io/badge/rails-8.1.3-red.svg)](https://rubyonrails.org/)
[![Database](https://img.shields.io/badge/database-PostgreSQL%2015+-blue.svg)](https://www.postgresql.org/)
[![Cache & Queue](https://img.shields.io/badge/cache%20%2F%20queue-Redis%207.x-orange.svg)](https://redis.io/)

Unending is a powerful, modern Ruby on Rails 8 application that serves as a real-time HTTP request catcher and mock server. It allows developers to create dedicated HTTP endpoints ("bins"), inspect incoming request details in real-time using Hotwire/Turbo Streams, and define custom mock rules to simulate complex API behaviors (such as dynamic status codes, latency, custom response headers, and Redis-backed rate limiting).

## Features

- **Real-time Request Inspection**: View incoming HTTP requests in real-time on your dashboard using ActionCable and Turbo Streams.
- **Rules-based Mocking**: Define rules to match incoming paths (with glob patterns and regex support) and return custom status codes, headers, and bodies.
- **Latency & Timeout Simulation**: Add a custom delay (`delay_ms`) to mock endpoints to simulate slow network connections or timeouts.
- **Redis-backed Rate Limiting**: Enforce rate limits on a per-rule basis, configured by period (minute, hour, day) and type (client IP, custom API Key header, or both).
- **Sensitive Header Masking**: Automatically mask security-sensitive headers (e.g., `Authorization`, `Cookie`, `X-API-Key`) to prevent data leakage.
- **Comprehensive Admin Panel**: A dedicated administrative dashboard powered by ActiveAdmin for complete manageability of all resources (Users, Bins, Mock Rules, and Captured Requests).
- **Secure Authentication**: Built-in authentication via Devise supporting Email/Password sign-ins, confirmation emails, and OAuth providers (Google OAuth2 and GitHub).
- **Containerized & Deployable**: Ready for production deployment using Docker, Kamal, and Thruster.
- **Environment-based Configuration**: Easily configured using Figaro (`config/application.yml`).

## Tech Stack

- **Backend**: Ruby on Rails 8 (v8.1.3+)
- **Ruby**: Ruby 4.0.3
- **Web Server**: Puma with Thruster proxy
- **Database**: PostgreSQL (v15+)
- **Caching & Rate Limiting**: Redis (v7.x)
- **Background Jobs**: Sidekiq & ActiveJob (supported by Solid Queue)
- **Frontend Stack**: Tailwind CSS, DartSass, Hotwire (Turbo & Stimulus)
- **Administration**: ActiveAdmin

## Prerequisites

- Ruby (v4.0.3 or higher)
- PostgreSQL (v15 or higher)
- Redis (v7.x or higher)
- bundler

## Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/iffardamahum/Unending
   cd Unending
   ```

2. **Install dependencies**:
   ```bash
   bundle install
   ```

3. **Setup environment configuration**:
   Create your local configuration file (using Figaro):
   ```bash
   cp config/application.yml.example config/application.yml
   ```

5. **Setup Database & Run Migrations**:
   ```bash
   bin/rails db:prepare
   ```

6. **Seed the database with demo data**:
   ```bash
   bin/rails db:seed
   ```
   *Note: This creates a default admin user `dev@example.com` with the password `password123`.*

7. **Build Tailwind CSS**:
   ```bash
   bin/rails tailwindcss:build
   ```

8. **Build Active Admin CSS**:
   ```bash
   bin/rails dartsass:build
   ```


## Usage

### Development

Run the server
```bash
bin/rails server
```
or if your IDE asking for "Select an app to open 'rails server'"
```bash
ruby bin/rails server
```

The app will be available at `http://localhost:3000`.

### Production

Run migrations and boot the server in production mode:
```bash
RAILS_ENV=production bin/rails db:migrate
RAILS_ENV=production bin/rails server
```


### Testing

# Run brakeman (security analysis)
```bash
bundle exec brakeman

# Run rubocop (style and lint checking)
bundle exec rubocop
```

## How Ingestion & Mock Rules Work

### Ingestion URL
Send HTTP requests (`GET`, `POST`, `PUT`, `DELETE`, etc.) to the ingest endpoint for your bin:
```
http://your-domain/b/:token
# or with subpaths:
http://your-domain/b/:token/v1/users
```
*(Replace `:token` with the unique bin token from your dashboard).*

### Mock Rule Matching
When an HTTP request is received:
1. Unending looks up active mock rules associated with the endpoint (`:token`), sorted by priority (highest first).
2. It matches the HTTP method and the request path (handling glob patterns like `/api/users*` or custom regular expressions).
3. If a match is found:
   - The response status, headers, and body are rendered as configured.
   - Any specified delay (`delay_ms`) is simulated using a sleep function before sending the response.
4. If no mock rule matches, it captures the request and returns:
   ```json
   {
     "request_id": "uuid-here",
     "message": "Request captured. No matching mock rule found.",
     "captured_at": "timestamp"
   }
   ```
5. All details (headers, payload, parameters, duration, matched rule ID, etc.) are recorded and pushed to the client browser in real-time via Turbo Streams.

### Redis-backed Rate Limiting
Mock rules can be individually rate-limited by defining:
- **Rate Limit Count**: Number of hits allowed.
- **Rate Limit Period**: `minute`, `hour`, or `day`.
- **Rate Limit Type**:
  - `ip`: Limits by client IP address.
  - `api_key`: Limits by API key in a custom header (e.g. `X-API-Key`).
  - `both`: Limits by IP-and-API-key combination.

If the limit is exceeded, Unending returns a `429 Too Many Requests` status code:
```json
{
  "error": "Rate limit exceeded!",
  "message": "This rule allows 5 request per minute."
}
```

## Security

- **Sensitive Header Masking**: Core headers such as `Authorization`, `Cookie`, `Set-Cookie`, `X-API-Key`, and `X-Auth-Token` are automatically masked as `[MASKED]` during request capture.
- **CSRF Protection**: Standard CSRF checking is enabled globally, except on the ingestion controller (`IngestController`), which accepts arbitrary external POST payloads with CSRF checking disabled.
- **Secure Admin Panel**: ActiveAdmin routes are protected under custom role authorization (`admin` or `super_admin`).
- **Security Scans**: Pre-configured with Brakeman for static analysis and Bundler Audit for dependency scanning.

## Environment Variables

Unending uses Figaro to manage environment variables in `config/application.yml`. The following variables can be configured:

### Database (PostgreSQL)
- `DB_HOST`: Database host (default: `localhost`).
- `DB_USERNAME`: Database username.
- `DB_PASSWORD`: Database password.
- `DB_NAME`: Database name.

### Caching & Jobs (Redis)
- `REDIS_HOST`: Redis server host (default: `127.0.0.1`).
- `REDIS_PORT`: Redis port (default: `6379`).
- `REDIS_DB`: Redis database number for caching/Sidekiq (default: `1`).
- `REDIS_PASSWORD`: Optional Redis password.


## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the `LICENSE` file for details.
