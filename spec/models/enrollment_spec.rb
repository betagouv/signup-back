require 'rails_helper'

RSpec.describe Enrollment, type: :model do
  let(:enrollment) { FactoryGirl.create(:enrollment) }

  %w[
    Document::CertificationResults
    Document::CNILVoucher
    Document::FranceConnectCompliance
    Document::LegalBasis
  ].each do |document_type|
    describe document_type do
      it 'can have document' do
        expect do
          enrollment.documents.create(
            type: document_type,
            attachment: Rack::Test::UploadedFile.new(Rails.root.join('spec/resources/test.pdf'), 'application/pdf')
          )
        end.to(change { enrollment.documents.count })
      end

      it 'can only have a document' do
        enrollment.documents.create(
          type: document_type,
          attachment: Rack::Test::UploadedFile.new(Rails.root.join('spec/resources/test.pdf'), 'application/pdf')
        )

        expect do
          enrollment.documents.create(
            type: document_type,
            attachment: Rack::Test::UploadedFile.new(Rails.root.join('spec/resources/test.pdf'), 'application/pdf')
          )
        end.not_to(change { enrollment.documents.count })
      end

      it "overwrites the document" do
        enrollment.documents.create(
          type: document_type,
          attachment: Rack::Test::UploadedFile.new(Rails.root.join('spec/resources/test.pdf'), 'application/pdf')
        )

        document = enrollment.documents.create(
          type: document_type,
          attachment: Rack::Test::UploadedFile.new(Rails.root.join('spec/resources/test.pdf'), 'application/pdf')
        )

        expect(enrollment.documents.last).to eq(document)
      end
    end
  end
end
