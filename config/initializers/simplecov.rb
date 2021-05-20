if ENV["COVERAGE"] && ENV["RAILS_ENV"] == "test"
  require "simplecov"
  p "LOAD"

  SimpleCov.start "rails"
  Rails.application.eager_load!
end
