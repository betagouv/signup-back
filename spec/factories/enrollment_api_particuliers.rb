# frozen_string_literal: true

FactoryGirl.define do
  factory :enrollment_api_particulier, class: Enrollment::ApiParticulier do
    fournisseur_de_donnees 'api-particulier'
    demarche "intitule" => "test", "description" => "test", "fondement_juridique" => "test"
    validation_de_convention true

    factory :sent_enrollment_api_particulier do
      siren '12345'
      state 'sent'
      donnees "conservation" => 12, "destinataires" => { "dgfip_avis_imposition" => "Destinaires des données"}
      scopes dgfip_avis_imposition: true
      contacts [
        {"id"=>"dpo", "heading"=>"Délégué à la protection des données", "nom" => "test", "email" => "test"},
        {"id"=>"responsable_traitement", "heading"=>"Responsable de traitement", "nom" => "test", "email" => "test"},
        {"id"=>"technique", "heading"=>"Responsable technique", "nom" => "test", "email" => "test"},
      ]

      factory :validated_enrollment_api_particulier do
        state 'validated'

        factory :technical_inputs_enrollment_api_particulier do
          state 'technical_inputs'
          ips_de_production 'test'

          factory :deployed_enrollment_api_particulier do
            state 'deployed'
          end
        end
      end
    end

    factory :refused_enrollment_api_particulier do
      state 'refused'
    end
  end
end
