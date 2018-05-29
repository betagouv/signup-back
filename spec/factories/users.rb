# frozen_string_literal: true

FactoryGirl.define do
  factory :user do
    email { "test#{rand(1..10_000)}@test.test" }

    factory :user_dgfip do
      provider 'dgfip'
    end

    factory :user_api_particulier do
      provider 'api_particulier'
    end

    factory :user_api_entreprise do
      provider 'api_entreprise'
    end
  end
end
