# frozen_string_literal: true

FactoryGirl.define do
  factory :user do
    email { "test#{rand(1..10_000)}@test.test" }
  end
end
