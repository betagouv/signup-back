# frozen_string_literal: true

FactoryGirl.define do
  factory :enrollment_api_entreprise, class: Enrollment::ApiEntreprise do
    fournisseur_de_donnees 'api-entreprise'
    demarche "intitule" => "test", "description" => "test", "fondement_juridique" => "test"
    validation_de_convention true

    factory :sent_enrollment_api_entreprise do
      siren '12345'
      state 'sent'
      donnees "conservation" => 12, "destinataires" => { "dgfip_avis_imposition" => "Destinaires des données"}
      scopes dgfip_avis_imposition: true
      contacts [
        {"id"=>"dpo", "heading"=>"Délégué à la protection des données", "nom" => "test", "email" => "test"},
        {"id"=>"responsable_traitement", "heading"=>"Responsable de traitement", "nom" => "test", "email" => "test"},
        {"id"=>"technique", "heading"=>"Responsable technique", "nom" => "test", "email" => "test"},
      ]

      factory :validated_enrollment_api_entreprise do
        state 'validated'
      end
    end

    factory :refused_enrollment_api_entreprise do
      state 'refused'
    end
  end
end
