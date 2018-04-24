# frozen_string_literal: true

FactoryGirl.define do
  factory :enrollment do
    fournisseur_de_donnees 'test'
    demarche "intitule" => "test", "description" => "test", "fondement_juridique" => "test"
    validation_de_convention true

    factory :sent_enrollment do
      siren '12345'
      state 'sent'
      donnees "conservation" => 12, "destinataires" => "test"
      contacts [
        {"id"=>"dpo", "heading"=>"Délégué à la protection des données", "nom" => "test", "email" => "test"},
        {"id"=>"responsable_traitement", "heading"=>"Responsable de traitement", "nom" => "test", "email" => "test"},
        {"id"=>"technique", "heading"=>"Responsable technique", "nom" => "test", "email" => "test"},
      ]
    end
  end
end
