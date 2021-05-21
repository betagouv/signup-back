FactoryBot.define do
  factory :document do
    type { "Document::DelegationServicePublic" }

    attachable { build(:enrollment, :franceconnect) }

    attachment do
      Rack::Test::UploadedFile.new(
        Rails.root.join(
          "spec/fixtures/dummy.pdf",
        )
      )
    end
  end
end
