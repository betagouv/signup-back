require 'rails_helper'

describe Enrollment::DgfipPolicy do
  subject { described_class }

  permissions_by_records_and_users(
    :send_application?,
    %i[enrollment_dgfip sent_enrollment_dgfip validated_enrollment_dgfip refused_enrollment_dgfip technical_inputs_enrollment_dgfip deployed_enrollment_dgfip],
    user: false,
    user_dgfip: false,
    user_api_particulier: false
  )
  permissions :send_application? do
    describe 'with a basic user applicant of an enrollment' do
      let(:enrollment) { create(:enrollment_dgfip) }
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
    %i[enrollment_dgfip validated_enrollment_dgfip refused_enrollment_dgfip technical_inputs_enrollment_dgfip deployed_enrollment_dgfip],
      user: false,
      user_dgfip: false,
      user_api_particulier: false
    )
    permissions_by_records_and_users(
      action,
      %i[sent_enrollment_dgfip],
      user: false,
      user_dgfip: true,
      user_api_particulier: false
    )
    permissions action do
      describe 'with a basic user applicant of an enrollment' do
        let(:enrollment) { create(:enrollment_dgfip) }
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
    %i[enrollment_dgfip sent_enrollment_dgfip validated_enrollment_dgfip refused_enrollment_dgfip technical_inputs_enrollment_dgfip deployed_enrollment_dgfip],
    user: false,
    user_dgfip: true,
    user_api_particulier: false
  )
  permissions :show_technical_inputs? do
    describe 'with a basic user applicant of a validated enrollment' do
      let(:enrollment) { create(:validated_enrollment_dgfip) }
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
    :send_technical_inputs?,
    %i[enrollment_dgfip sent_enrollment_dgfip validated_enrollment_dgfip refused_enrollment_dgfip technical_inputs_enrollment_dgfip deployed_enrollment_dgfip],
    user: false,
    user_dgfip: false,
    user_api_particulier: false
  )
  permissions :send_technical_inputs? do
    describe 'with a basic user applicant of a validated enrollment' do
      let(:enrollment) { create(:validated_enrollment_dgfip) }
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
    %i[enrollment_dgfip sent_enrollment_dgfip validated_enrollment_dgfip refused_enrollment_dgfip deployed_enrollment_dgfip],
    user: false,
    user_dgfip: false,
    user_api_particulier: false
  )
  permissions_by_records_and_users(
    :deploy_application?,
    %i[technical_inputs_enrollment_dgfip],
    user: false,
    user_dgfip: true,
    user_api_particulier: false
  )
  permissions :deploy_application? do
    describe 'with a basic user applicant of a validated enrollment' do
      let(:enrollment) { create(:validated_enrollment_dgfip) }
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
