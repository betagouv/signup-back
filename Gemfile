source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem "carrierwave"
gem "carrierwave-i18n"
gem "devise"
gem "kaminari"
gem "mailjet"
gem "omniauth-oauth2"
gem "pg"
gem "puma", "~> 3.7"
gem "pundit"
gem "rails", "~> 5.2.3"
gem "rails-i18n"
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
  gem "rubocop", "~> 0.73.0"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
end

gem "active_model_serializers", "~> 0.10.9"
