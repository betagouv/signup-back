FactoryBot.define do
  sequence(:email) { |n| "user#{n}@whatever.gouv.fr" }

  factory :user do
    email
  end
end
