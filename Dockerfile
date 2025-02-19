# syntax=docker/dockerfile:1
# check=error=true

FROM ruby:3.2.0

# Install dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    libpq-dev \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /rails

# Copy Gemfile and install dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy the rest of the application
COPY . .

# Make the entrypoint script executable
RUN chmod +x /rails/bin/docker-entrypoint

# Set the entrypoint script
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the server by default
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]

#bir şeyler