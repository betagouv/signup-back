require 'rails_helper'

describe Enrollment::ApiParticulierPolicy do
  subject { described_class }

  permissions_by_records_and_users(
    :send_application?,
    %i[enrollment_api_particulier sent_enrollment_api_particulier validated_enrollment_api_particulier refused_enrollment_api_particulier technical_inputs_enrollment_api_particulier deployed_enrollment_api_particulier],
    user: false,
    user_api_particulier: false,
    user_dgfip: false
  )
  permissions :send_application? do
    describe 'with a basic user applicant of an enrollment' do
      let(:enrollment) { create(:enrollment_api_particulier) }
      let(:user) { create(:user) }
      before do
        user.add_role(:applicant, enrollment)
      end

      it 'allow access' do
        expect(subject).to permit(user, enrollment)
      end
    end
  end

  %i[validate_application? refuse_application? review_application?].each do |action|
    permissions_by_records_and_users(
      action,
    %i[enrollment_api_particulier validated_enrollment_api_particulier refused_enrollment_api_particulier technical_inputs_enrollment_api_particulier deployed_enrollment_api_particulier],
      user: false,
      user_api_particulier: false,
      user_dgfip: false
    )
    permissions_by_records_and_users(
      action,
      %i[sent_enrollment_api_particulier],
      user: false,
      user_api_particulier: true,
      user_dgfip: false
    )
    permissions action do
      describe 'with a basic user applicant of an enrollment' do
        let(:enrollment) { create(:enrollment_api_particulier) }
        let(:user) { create(:user) }
        before do
          user.add_role(:applicant, enrollment)
        end

        it 'deny access' do
          expect(subject).not_to permit(user, enrollment)
        end
      end
    end
  end

  permissions_by_records_and_users(
    :show_technical_inputs?,
    %i[enrollment_api_particulier sent_enrollment_api_particulier validated_enrollment_api_particulier refused_enrollment_api_particulier technical_inputs_enrollment_api_particulier deployed_enrollment_api_particulier],
    user: false,
    user_api_particulier: false,
    user_dgfip: false
  )
  permissions :show_technical_inputs? do
    describe 'with a basic user applicant of a validated enrollment' do
      let(:enrollment) { create(:validated_enrollment_api_particulier) }
      let(:user) { create(:user) }
      before do
        user.add_role(:applicant, enrollment)
      end

      it 'allow access' do
        expect(subject).not_to permit(user, enrollment)
      end
    end
  end

  permissions_by_records_and_users(
    :send_technical_inputs?,
    %i[enrollment_api_particulier sent_enrollment_api_particulier validated_enrollment_api_particulier refused_enrollment_api_particulier technical_inputs_enrollment_api_particulier deployed_enrollment_api_particulier],
    user: false,
    user_api_particulier: false,
    user_dgfip: false
  )
  permissions :send_technical_inputs? do
    describe 'with a basic user applicant of a validated enrollment' do
      let(:enrollment) { create(:validated_enrollment_api_particulier) }
      let(:user) { create(:user) }
      before do
        user.add_role(:applicant, enrollment)
      end

      it 'allow access' do
        expect(subject).to permit(user, enrollment)
      end
    end
  end

  permissions_by_records_and_users(
    :deploy_application?,
    %i[enrollment_api_particulier sent_enrollment_api_particulier validated_enrollment_api_particulier refused_enrollment_api_particulier deployed_enrollment_api_particulier],
    user: false,
    user_api_particulier: false,
    user_dgfip: false
  )
  permissions_by_records_and_users(
    :deploy_application?,
    %i[technical_inputs_enrollment_api_particulier],
    user: false,
    user_api_particulier: true,
    user_dgfip: false
  )
  permissions :deploy_application? do
    describe 'with a basic user applicant of a validated enrollment' do
      let(:enrollment) { create(:validated_enrollment_api_particulier) }
      let(:user) { create(:user) }
      before do
        user.add_role(:applicant, enrollment)
      end

      it 'deny access' do
        expect(subject).not_to permit(user, enrollment)
      end
    end
  end
end
