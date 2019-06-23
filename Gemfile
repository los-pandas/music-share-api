# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.6.0'

# Web API
gem 'json'
gem 'puma', '~>3.11'
gem 'roda', '~>3.6'

# Configuration
gem 'econfig'
gem 'rake'

# Debugging
gem 'pry'
gem 'rack-test'
gem 'simplecov'

# external services
gem 'http'

# Database
gem 'hirb'
gem 'sequel'
group :development, :test do
  gem 'sequel-seed'
  gem 'sqlite3'
end

group :production do
  gem 'pg'
end

# Security
gem 'bundler-audit'
gem 'rbnacl', '~>6.0'

# Testing
group :test do
  gem 'minitest'
  gem 'minitest-rg'
  gem 'webmock'
end

# Development
group :development do
  gem 'rubocop'
  gem 'rubocop-performance'
end
