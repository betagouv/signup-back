FactoryBot.define do
  factory :enrollment do
    status { "pending" }
    intitule { "Intitulé" }

    trait :pending
    trait :modification_pending

    transient do
      organization_kind { :clamart }
    end

    after(:build) do |enrollment, evaluator|
      organization = build(:organization, evaluator.organization_kind)

      enrollment.siret = organization["siret"]

      if enrollment.user
        enrollment.user.organizations ||= []
        enrollment.user.organizations << organization
      else
        enrollment.user = build(:user, organizations: [organization])
      end

      enrollment.organization_id = organization["id"]
    end

    before(:create) do |enrollment|
      stub_entreprise_data_etablissement_call(enrollment.siret)
    end

    trait :sent do
      after(:create) do |enrollment|
        enrollment.update!(
          status: "sent"
        )
      end

      with_dpo
      with_responsable_traitement
      with_data_retention

      cgu_approved { true }
    end

    trait :with_dpo do
      dpo { build(:user, :dpo) }

      after(:build) do |enrollment|
        enrollment.dpo_label ||= enrollment.dpo.given_name
        enrollment.dpo_phone_number ||= enrollment.dpo.phone_number
      end
    end

    trait :with_responsable_traitement do
      responsable_traitement { build(:user, :responsable_traitement) }

      after(:build) do |enrollment|
        enrollment.responsable_traitement_label ||= enrollment.responsable_traitement.given_name
        enrollment.responsable_traitement_phone_number ||= enrollment.responsable_traitement.phone_number
      end
    end

    trait :with_data_retention do
      data_retention_period { 24 }
      data_recipients { "Agents" }
      data_retention_comment { nil }
    end

    trait :validated do
      status { "validated" }

      with_dpo
      with_responsable_traitement
      with_data_retention

      cgu_approved { true }
    end

    trait :public do
      validated
    end

    trait :api_entreprise do
      target_api { "api_entreprise" }
      intitule { "Marché publics de la ville de Clamart" }

      contacts do
        [
          {
            id: "technique",
            email: "user-technique@clamart.fr"
          },
          {
            id: "metier",
            email: "user-metier@clamart.fr"
          }
        ]
      end
    end

    trait :api_particulier do
      target_api { "api_particulier" }
      intitule { "Délivrance des titres de transport de la ville de Clamart" }

      contacts do
        [
          {
            id: "technique",
            email: "user-technique@clamart.fr"
          },
          {
            id: "metier",
            email: "user-metier@clamart.fr"
          }
        ]
      end
    end

    trait :franceconnect do
      target_api { "franceconnect" }
      intitule { "Connexion aux démarches de la ville de Clamart" }
      description { "Permettre aux citoyens de se connecter sur le portail des démarches administratives" }
      fondement_juridique_title { "Arrêté du 8 novembre 2018" }
      fondement_juridique_url { "https://www.legifrance.gouv.fr/affichTexte.do?cidTexte=JORFTEXT000000886460" }

      scopes do
        {
          email: true,
          gender: true,
          openid: true,
          birthdate: true,
          given_name: true,
          family_name: true,
          birthcountry: true
        }
      end

      contacts do
        [
          {
            id: "technique",
            email: "user-technique@clamart.fr"
          }
        ]
      end
    end
  end
end
