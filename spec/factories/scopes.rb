FactoryGirl.define do
  factory :scope do
    name "MyString"
    human_name "MyString"
    description "MyText"
    services [{}]
    resource_provider
  end
end
