# frozen_string_literal: true

FactoryGirl.define do
  factory :document, class: Document::LegalBasis do
    attachment { Rack::Test::UploadedFile.new(Rails.root.join('spec/resources/test.pdf'), 'application/pdf') }
    attachable { create(:enrollment) }
  end
end
