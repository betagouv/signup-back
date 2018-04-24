# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Enrollment, type: :model do
  let(:enrollment) { FactoryGirl.create(:enrollment) }

  let(:attributes) do
    JSON.parse(
      <<-EOF
      {
        "demarche": {
        "intitule": "test"
        },
        "contacts": [],
        "scopes": {},
        "siren": "12345",
        "donnees": {},
        "validation_de_convention": true,
        "fournisseur_de_donnees": "api-particulier"
      }
      EOF
    )
  end
  after do
    DocumentUploader.new(Enrollment, :attachment).remove!
  end

  it 'can have messages attached to it' do
    expect do
      enrollment.messages.create(content: 'test')
    end.to change { enrollment.messages.count }
  end

  it "has a valid schema" do
    enrollment = Enrollment.create(attributes)

    enrollment_attributes = enrollment.as_json
    enrollment_attributes.delete('created_at')
    enrollment_attributes.delete('updated_at')
    enrollment_attributes.delete('id')
    attributes['state'] = 'pending'

    expect(enrollment_attributes).to eq(attributes)
  end

  describe 'Workflow' do
    let(:enrollment) { FactoryGirl.create(:enrollment) }
    it 'should start on pending state' do
      expect(enrollment.state).to eq('pending')
    end

    # it 'cannot send application if invalid' do
    #   enrollment.send_application

    #   expect(enrollment.state).to eq('pending')
    # end

    describe 'The enrollment is valid' do
      let(:enrollment) { FactoryGirl.create(:sent_enrollment, state: :pending) }

      it 'can go on sent state' do
        enrollment.send_application

        expect(enrollment.state).to eq('sent')
      end
    end

    describe 'Enrollment is in sent state' do
      let(:enrollment) { FactoryGirl.create(:sent_enrollment) }
      it 'can validate application' do
        enrollment.validate_application

        expect(enrollment.state).to eq('validated')
      end

      it 'can refuse application' do
        enrollment.refuse_application

        expect(enrollment.state).to eq('refused')
      end

      it 'can review application' do
        enrollment.review_application

        expect(enrollment.state).to eq('pending')
      end
    end
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
end
