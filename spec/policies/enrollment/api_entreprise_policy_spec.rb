require 'rails_helper'

describe Enrollment::ApiEntreprisePolicy do
  subject { described_class }

  permissions_by_records_and_users(
    :send_application?,
    %i[enrollment_api_entreprise sent_enrollment_api_entreprise validated_enrollment_api_entreprise refused_enrollment_api_entreprise],
    user: false,
    user_api_particulier: false,
    user_api_entreprise: false,
    user_dgfip: false
  )
  permissions :send_application? do
    describe 'with a basic user applicant of an enrollment' do
      let(:enrollment) { FactoryGirl.create(:enrollment_api_entreprise) }
      let(:user) { FactoryGirl.create(:user) }
      before do
        user.add_role(:applicant, enrollment)
      end

      it 'allow access' do
        expect(subject).to permit(user, enrollment)
      end
    end
  end

  %i[sent_enrollment_api_entreprise validated_enrollment_api_entreprise refused_enrollment_api_entreprise].each do |enrollment_factory|
    permissions :send_application? do
      describe "with a basic user applicant of an #{enrollment_factory}" do
        let(:enrollment) { FactoryGirl.create(enrollment_factory) }
        let(:user) { FactoryGirl.create(:user) }
        before do
          user.add_role(:applicant, enrollment)
        end

        it 'deny access' do
          expect(subject).not_to permit(user, enrollment)
        end
      end
    end
  end

  %i[validate_application? refuse_application? review_application?].each do |action|
    permissions_by_records_and_users(
      action,
    %i[enrollment_api_entreprise validated_enrollment_api_entreprise refused_enrollment_api_entreprise],
      user: false,
      user_api_particulier: false,
      user_api_entreprise: false,
      user_dgfip: false
    )
    permissions_by_records_and_users(
      action,
      %i[sent_enrollment_api_entreprise],
      user: false,
      user_api_particulier: false,
      user_api_entreprise: true,
      user_dgfip: false
    )
    %i[enrollment_api_entreprise sent_enrollment_api_entreprise validated_enrollment_api_entreprise refused_enrollment_api_entreprise].each do |enrollment_factory|
      permissions action do
        describe "with a basic user applicant of an #{enrollment_factory}" do
          let(:enrollment) { FactoryGirl.create(enrollment_factory) }
          let(:user) { FactoryGirl.create(:user) }
          before do
            user.add_role(:applicant, enrollment)
          end

          it 'deny access' do
            expect(subject).not_to permit(user, enrollment)
          end
        end
      end
    end
  end
end
