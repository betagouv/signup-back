FactoryGirl.define do
  factory :message do
    enrollment
    content 'MyText'
    user
  end
end
