FactoryGirl.define do
  factory :user do
    email { "test#{rand(1..10000)}@test.test" }
  end
end
