source "https://rubygems.org"

# Core Rails dependencies
gem "rails", "~> 8.1.1"
gem "propshaft"
gem "sqlite3", ">= 2.1"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"
gem "bootsnap", require: false
gem "kamal", require: false
gem "thruster", require: false
gem "image_processing", "~> 1.2"

# ⭐️ GOOGLE SHEETS API
gem "google-apis-sheets_v4"
gem "google-apis-drive_v3"
gem "googleauth"

# ⭐️ .env dosyalarını okumak için DOTENV — BURASI KRİTİK
group :development, :test do
  gem "dotenv-rails"   # ❗ SENDE EKSİK OLAN KISIM BU

  # Debugging tools
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Security audits
  gem "bundler-audit", require: false
  gem "brakeman", require: false

  # Linting
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
