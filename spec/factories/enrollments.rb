# frozen_string_literal: true

FactoryGirl.define do
  factory :enrollment do
    fournisseur_de_service 'test'
    validation_de_convention true
  end
end
