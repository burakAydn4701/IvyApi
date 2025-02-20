source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.1"

# Use postgresql as the database
gem "pg"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Move dotenv-rails out of groups so it's available in production
gem 'dotenv-rails'

# Remove or comment out thruster
# gem "thruster", require: false

# Remove solid gems that might be causing issues
# gem "solid_cache"
# gem "solid_queue"
# gem "solid_cable"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
gem "rack-cors"

# Add cloudinary gem
gem 'cloudinary'

# Remove or comment out if present:
# gem "aws-sdk-s3"
# gem "image_processing"

group :development, :test do
  # Use sqlite3 as the database for development/test
  gem "sqlite3", "~> 1.4"
  
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
end


