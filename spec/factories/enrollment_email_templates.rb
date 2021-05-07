FactoryBot.define do
  factory :enrollment_email_template do
    action_name { "review_application" }
    plain_text_content { "Hello world!" }
  end
end
