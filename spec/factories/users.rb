# frozen_string_literal: true

FactoryGirl.define do
  factory :user do
    email { nano_timestamp_string }
    uid   { nano_timestamp_string }

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
