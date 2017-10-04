# frozen_string_literal: true

FactoryGirl.define do
  factory :document do
    type 'Document::LegalBasis'
    attachment { Rack::Test::UploadedFile.new(Rails.root.join('spec/resources/test.pdf'), 'application/pdf') }
    enrollment
  end
end
