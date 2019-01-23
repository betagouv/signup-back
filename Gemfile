# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'carrierwave'
gem 'carrierwave-i18n'
gem 'devise'
gem 'faraday_middleware'
gem 'json-schema'
gem 'jwt'
gem 'mailjet'
gem 'omniauth-oauth2'
gem 'pg'
gem 'prawn-rails'
gem 'prawn-table'
gem 'puma', '~> 3.7'
gem 'pundit'
gem 'rails', '~> 5.1.4'
gem 'rails-i18n'
gem 'rmagick'
gem 'rolify'
gem 'rubyzip'
gem 'state_machines-activerecord'
gem 'mongo', '2.5.1'

group :development, :test do
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'rspec-rails'
  gem 'simplecov'
  gem 'webmock'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
