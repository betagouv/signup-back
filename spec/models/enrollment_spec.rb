require 'rails_helper'

RSpec.describe Enrollment, type: :model do
  let(:enrollment) { FactoryGirl.create(:enrollment) }
  after do
    DocumentUploader.new(Enrollment, :attachment).remove!
  end

  Enrollment::DOCUMENT_TYPES.each do |document_type|
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

      it 'overwrites the document' do
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

  describe 'workflow' do
    it 'should start on initial state' do
      expect(enrollment.state).to eq('filled_application')
    end

    it 'is on completed_application state if all documents uploaded' do
      Enrollment::DOCUMENT_TYPES.each do |document_type|
        enrollment.documents.create(
          type: document_type,
          attachment: Rack::Test::UploadedFile.new(Rails.root.join('spec/resources/test.pdf'), 'application/pdf')
        )
      end

      expect(enrollment.state).to eq('completed_application')
    end

    it 'is on waiting_for_approval state if all documents uploaded and apllicant set' do
      Enrollment::DOCUMENT_TYPES.each do |document_type|
        enrollment.documents.create(
          type: document_type,
          attachment: Rack::Test::UploadedFile.new(Rails.root.join('spec/resources/test.pdf'), 'application/pdf')
        )
      end
      enrollment.update(applicant: { email: 'test@test.test' })

      expect(enrollment.state).to eq('waiting_for_approval')
    end
  end
end
