FROM ruby:3.2


# Install Node.js (version 18.x) and Yarn, along with system dependencies
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
 && apt-get update -qq \
 && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    nodejs \
    git \
    curl \
 && npm install -g yarn \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*


# Set working directory
WORKDIR /app

# Install bundler
RUN gem install bundler

# Copy gem files and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy the entire app
COPY . .

# Force reinstall node modules and clear cache
RUN yarn install && \
    yarn add --dev babel-loader@^8.2.3 && \
    yarn add --dev \
      @babel/core \
      @babel/preset-env \
      @babel/preset-react \
      @babel/plugin-transform-runtime \
      @babel/plugin-syntax-dynamic-import \
      @babel/plugin-proposal-class-properties \
      @babel/plugin-proposal-object-rest-spread 
      

# Expose ports for Rails and Webpack dev server
EXPOSE 3000 3035

# Default command: skip asset precompile in dev
CMD ["bash", "-c", "rm -f tmp/pids/server.pid && bundle exec rails s -b 0.0.0.0"]

