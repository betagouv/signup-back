require 'rails_helper'

RSpec.describe Enrollment::SendApplicationJob, type: :job do
  let(:enrollment) { create(:enrollment_api_particulier) }
  let(:api_particulier_users) { create_list(:user, 10, provider: 'api_particulier') }
  let(:user) { create(:user) }
  subject { described_class.new }

  describe '#perform' do
    it 'does not send mail' do
      expect do
        subject.perform(enrollment, user)
      end.not_to change(EnrollmentMailer, :deliveries)
    end
    describe 'user is applicant of enrollment' do
      before do
        user.add_role(:applicant, enrollment)
      end

      it 'does not send email' do
        expect do
          subject.perform(enrollment, user)
        end.not_to change(EnrollmentMailer, :deliveries)
      end
      describe 'there is api_particulier users in database' do
        before do
          api_particulier_users
        end

        it 'sends email' do
          expect do
            subject.perform(enrollment, user)
          end.to change(EnrollmentMailer, :deliveries)
        end
      end
    end
  end
end
