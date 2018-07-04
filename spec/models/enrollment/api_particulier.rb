# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Enrollment::Dgfip, type: :model do
  let(:enrollment) { create(:enrollment_api_particulier) }

  let(:attributes) do
    enrollment.attributes
  end

  after do
    DocumentUploader.new(Enrollment, :attachment).remove!
  end

  it 'can have messages attached to it' do
    expect do
      enrollment.messages.create(content: 'test')
    end.to change { enrollment.messages.count }
  end

  describe 'enrollment has an applicant' do
    let(:applicant) { create(:user) }
    before do
      applicant.add_role(:applicant, enrollment)
    end

    describe '#other_party' do
      describe 'There is an api_particulier_user in database' do
        let(:api_particulier_user) { create(:user, provider: 'api_particulier') }
        before do
          api_particulier_user
        end

        it 'includes api_particulier_user for applicant' do
          expect(enrollment.other_party(applicant)).to include(api_particulier_user)
        end

        it 'includes applicant for api_particulier_user' do
          expect(enrollment.other_party(api_particulier_user)).to include(applicant)
        end

        it 'does not includes api_particulier_user for api_particulier_user' do
          expect(enrollment.other_party(api_particulier_user)).not_to include(api_particulier_user)
        end

        it 'does not includes applicant for applicant' do
          expect(enrollment.other_party(applicant)).not_to include(applicant)
        end
      end
    end
  end

  describe 'Workflow' do
    let(:new_enrollment) { Enrollment::ApiParticulier.new }
    let(:enrollment) { create(:enrollment_api_particulier) }

    it 'should start on pending state' do
      expect(enrollment.state).to eq('pending')
    end

    it 'cannot send application if invalid' do
      new_enrollment.send_application

      expect(new_enrollment.state).to eq('pending')
    end

    describe 'The enrollment is valid to be sent' do
      let(:enrollment) { create(:sent_enrollment, state: :pending) }

      it 'can go on sent state' do
        enrollment.send_application

        expect(enrollment.state).to eq('sent')
      end

      it 'performs associated job' do
        expect_any_instance_of(Enrollment::SendApplicationJob).to receive(:perform_now)
        enrollment.send_application!(user: create(:user))
      end

      it "don't perform job if not existing" do
        enrollment.loop_without_job!
      end
    end

    describe 'Enrollment is in sent state' do
      let(:enrollment) { create(:sent_enrollment) }
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

    describe 'Enrollment is in validated state' do
      let(:enrollment) { create(:validated_enrollment_api_particulier) }

      before do
        enrollment.update_attribute(:state, 'validated')
      end

      it 'cannot send technical inputs' do
        expect(enrollment.send_technical_inputs).to be_falsey
      end

      describe 'the enrollment is valid to send_technical_inputs' do
        before do
          enrollment.ips_de_production = "test d'ips de production"
        end

        it 'can go send_application' do
          expect(enrollment.send_technical_inputs).to be_truthy
        end
      end
    end

    describe 'Enrollment is in technical_inputs state' do
      let(:enrollment) { create(:technical_inputs_enrollment_api_particulier) }

      it 'can deploy application' do
        expect(enrollment.deploy_application).to be_truthy
      end
    end
  end

  Enrollment::ApiParticulier::DOCUMENT_TYPES.each do |document_type|
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
