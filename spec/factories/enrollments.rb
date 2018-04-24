# frozen_string_literal: true

FactoryGirl.define do
  factory :enrollment do
    demarche intitule: 'test'
    validation_de_convention true

    factory :sent_enrollment do
      state 'sent'
    end
  end
end
