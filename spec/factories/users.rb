FactoryBot.define do
  sequence(:email) { |n| "user#{n}@whatever.gouv.fr" }

  factory :user do
    email

    trait :with_all_infos do
      given_name { 'Jean' }
      family_name { 'Dupont' }
      phone_number { '0636656565' }
      job { 'Administrateur' }

      organizations do
        %w[
          DINUM
        ]
      end

      roles do
        %w[
          administrator
        ]
      end
    end
  end
end
