# frozen_string_literal: true

FactoryGirl.define do
  factory :enrollment do
    service_provider name: 'test'
    scopes number_of_tax_shares: false, tax_address: false,
           non_wadge_income: false, family_situation: false, support_payments: false,
           deficit: false, housing_tax: false, total_gross_income: false,
           world_income: false
    legal_basis comment: 'test', attachment: nil
    service_description main: 'test', deployment_date: nil, seasonality: [{type: 'year', max_charge: 12}],
                        max_charge: nil
    agreement true
  end
end
