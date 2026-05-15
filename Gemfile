source "https://rubygems.org"

ruby "4.0.3"

# Rails 8 Framework
gem "rails", "~> 8.1.3"

# Modern asset pipeline
gem "propshaft"

# Database - PostgreSQL 15+
gem "pg", "~> 1.1"

# Web server
gem "puma", ">= 5.0"

# Frontend stack: Tailwind + Turbo + Stimulus
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"

# JSON API
gem "jbuilder"

# Authentication
gem "devise", "~> 4.9"
gem "bcrypt", "~> 3.1.7"

# Admin panel
gem "activeadmin", "~> 3.0"
gem "pundit"

# Cache - Redis 7.x
gem "redis", "~> 5.0"

# Pagination & Search
gem "pagy", "~> 9.0"
gem "ransack", "~> 4.1"

# HTTP client (for proxying/forwarding requests)
gem "httpx"

# Background jobs
gem "sidekiq", "~> 7.0"

# Database-backed Rails solid adapters (ships with Rails 8)
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Boot cache
gem "bootsnap", require: false

# Deployment
gem "kamal", require: false
gem "thruster", require: false

# Timezone data for Windows/JRuby
gem "tzinfo-data", platforms: %i[ windows jruby ]

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "rspec-rails", "~> 7.0"
  gem "factory_bot_rails"
  gem "faker"
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
end

gem "figaro", "~> 1.3"
gem "fiddle"