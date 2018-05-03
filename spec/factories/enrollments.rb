# frozen_string_literal: true

FactoryGirl.define do
  factory :enrollment, class: Enrollment::ApiParticulier do
    fournisseur_de_donnees 'api-particulier'
    demarche "intitule" => "test", "description" => "test", "fondement_juridique" => "test"
    validation_de_convention true

    factory :sent_enrollment do
      siren '12345'
      state 'sent'
      donnees "conservation" => 12, "destinataires" => "test"
      scopes dgfip_avis_imposition: true
      contacts [
        {"id"=>"dpo", "heading"=>"Délégué à la protection des données", "nom" => "test", "email" => "test"},
        {"id"=>"responsable_traitement", "heading"=>"Responsable de traitement", "nom" => "test", "email" => "test"},
        {"id"=>"technique", "heading"=>"Responsable technique", "nom" => "test", "email" => "test"},
      ]
    end
  end
end
