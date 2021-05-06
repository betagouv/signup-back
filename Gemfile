source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem "carrierwave"
gem "carrierwave-i18n"
gem "devise"
gem "http"
gem "kaminari"
gem "mailjet"
gem "omniauth-oauth2"
gem "pg"
gem "puma", "~> 3.12"
gem "pundit"
gem "rails", "~> 5.2.5"
gem "rails-i18n"
gem "sib-api-v3-sdk"
gem "state_machines-activerecord"

group :development, :test do
  gem "database_cleaner"
  gem "factory_girl_rails"
  gem "rspec-rails"
  gem "simplecov"
  gem "webmock"
end

group :development do
  gem "listen", ">= 3.0.5", "< 3.2"
  gem "rubocop"
  gem "standardrb"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
end

gem "active_model_serializers", "~> 0.10.9"
