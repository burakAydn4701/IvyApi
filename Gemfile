source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.1"

# Use postgresql as the database
gem "pg", "~> 1.5"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", "~> 1.18", require: false

# Move dotenv-rails out of groups so it's available in production
gem 'dotenv-rails'

# Remove or comment out thruster
# gem "thruster", require: false

# Remove solid gems that might be causing issues
# gem "solid_cache"
# gem "solid_queue", "~> 0.2.1"
# gem "solid_cable"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
gem "rack-cors", "~> 2.0"

# Add cloudinary gem
gem 'cloudinary'

# Remove or comment out if present:
# gem "aws-sdk-s3"
# gem "image_processing"

# API and serialization
gem "jbuilder", "~> 2.11"

# Authentication
gem "bcrypt", "~> 3.1.20"
gem "jwt", "~> 2.8"

# Redis for Action Cable
gem "redis", "~> 5.0"

# Use good_job as an alternative to solid_queue
gem "good_job", "~> 3.21"

# For generating slugs
gem 'friendly_id', '~> 5.5.0'
# For generating public IDs
gem 'nanoid'

group :development, :test do
  # Use sqlite3 as the database for development/test
  gem "sqlite3", "~> 1.4"
  
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", "~> 1.9", platforms: %i[ mri mingw x64_mingw ]

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end


