# frozen_string_literal: true

FactoryGirl.define do
  factory :user do
    email { "#{nano_timestamp_string}@test.user" }
    uid   { nano_timestamp_string }
  end
end
