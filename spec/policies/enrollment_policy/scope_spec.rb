require 'rails_helper'

describe EnrollmentPolicy::Scope do
  describe '#resolve' do
    describe 'with Enrollment::ApiParticulier ActiveRecord::Relation' do
      let(:relation) { Enrollment.all }

      describe 'there are api_particulier, api_entreprise and dgfip enrollments in database' do
        let(:api_particulier_enrollments) { FactoryGirl.create_list(:enrollment_api_particulier, 3) }
        let(:dgfip_enrollments) { FactoryGirl.create_list(:enrollment_dgfip, 4) }
        let(:api_entreprise_enrollments) { FactoryGirl.create_list(:enrollment_api_entreprise, 5) }
        before do
          api_particulier_enrollments && api_entreprise_enrollments && dgfip_enrollments
        end

        describe 'with a basic user' do
          let(:user) { FactoryGirl.create(:user) }
          subject { described_class.new(user, relation) }

          it 'returns an empty relation' do
            expect(subject.resolve).to match_array([])
          end
        end

        describe 'with a api_particulier user' do
          let(:user) { FactoryGirl.create(:user_api_particulier) }
          subject { described_class.new(user, relation) }

          it 'returns api_particulier enrollments' do
            expect(subject.resolve).to match_array(api_particulier_enrollments)
          end
        end

        describe 'with a dgfip user' do
          let(:user) { FactoryGirl.create(:user_dgfip) }
          subject { described_class.new(user, relation) }

          it 'returns dgfip enrollments' do
            expect(subject.resolve).to match_array(dgfip_enrollments)
          end
        end

        describe 'with a api_entreprise user' do
          let(:user) { FactoryGirl.create(:user_api_entreprise) }
          subject { described_class.new(user, relation) }

          it 'returns api_entreprise enrollments' do
            expect(subject.resolve).to match_array(api_entreprise_enrollments)
          end
        end

        describe 'with a user applicant of the api_particulier enrollments' do
          let(:user) { FactoryGirl.create(:user) }
          let(:enrollment) { api_particulier_enrollments.first }
          subject { described_class.new(user, relation) }
          before do
            user.add_role(:applicant, enrollment)
          end

          it 'returns the enrollment' do
            expect(subject.resolve).to match_array([enrollment])
          end
        end
      end
    end

    describe 'with Enrollment::ApiParticulier ActiveRecord::Relation' do
      let(:relation) { Enrollment::ApiParticulier.all }

      describe 'there are api_particulier, api_entreprise and dgfip enrollments in database' do
        let(:api_particulier_enrollments) { FactoryGirl.create_list(:enrollment_api_particulier, 3) }
        let(:dgfip_enrollments) { FactoryGirl.create_list(:enrollment_dgfip, 4) }
        let(:api_entreprise_enrollments) { FactoryGirl.create_list(:enrollment_api_entreprise, 5) }
        before do
          api_particulier_enrollments && api_entreprise_enrollments && dgfip_enrollments
        end

        describe 'with a basic user' do
          let(:user) { FactoryGirl.create(:user) }
          subject { described_class.new(user, relation) }

          it 'returns an empty relation' do
            expect(subject.resolve).to match_array([])
          end
        end

        describe 'with a api_particulier user' do
          let(:user) { FactoryGirl.create(:user_api_particulier) }
          subject { described_class.new(user, relation) }

          it 'returns api_particulier enrollments' do
            expect(subject.resolve).to match_array(api_particulier_enrollments)
          end
        end

        describe 'with a user applicant of the api_particulier enrollments' do
          let(:user) { FactoryGirl.create(:user) }
          let(:enrollment) { api_particulier_enrollments.first }
          subject { described_class.new(user, relation) }
          before do
            user.add_role(:applicant, enrollment)
          end

          it 'returns the enrollment' do
            expect(subject.resolve).to match_array([enrollment])
          end
        end
      end
    end

    describe 'with Enrollment::ApiEntreprise ActiveRecord::Relation' do
      let(:relation) { Enrollment::ApiEntreprise.all }

      describe 'there are api_particulier, api_entreprise and dgfip enrollments in database' do
        let(:api_particulier_enrollments) { FactoryGirl.create_list(:enrollment_api_particulier, 3) }
        let(:dgfip_enrollments) { FactoryGirl.create_list(:enrollment_dgfip, 4) }
        let(:api_entreprise_enrollments) { FactoryGirl.create_list(:enrollment_api_entreprise, 5) }
        before do
          api_particulier_enrollments && api_entreprise_enrollments && dgfip_enrollments
        end

        describe 'with a basic user' do
          let(:user) { FactoryGirl.create(:user) }
          subject { described_class.new(user, relation) }

          it 'returns an empty relation' do
            expect(subject.resolve).to match_array([])
          end
        end

        describe 'with a api_entreprise user' do
          let(:user) { FactoryGirl.create(:user_api_entreprise) }
          subject { described_class.new(user, relation) }

          it 'returns api_entreprise enrollments' do
            expect(subject.resolve).to match_array(api_entreprise_enrollments)
          end
        end

        describe 'with a user applicant of the api_entreprise enrollments' do
          let(:user) { FactoryGirl.create(:user) }
          let(:enrollment) { api_entreprise_enrollments.first }
          subject { described_class.new(user, relation) }
          before do
            user.add_role(:applicant, enrollment)
          end

          it 'returns the enrollment' do
            expect(subject.resolve).to match_array([enrollment])
          end
        end
      end
    end

    describe 'with Enrollment::Dgfip ActiveRecord::Relation' do
      let(:relation) { Enrollment::Dgfip.all }

      describe 'there are api_particulier, api_entreprise and dgfip enrollments in database' do
        let(:api_particulier_enrollments) { FactoryGirl.create_list(:enrollment_api_particulier, 3) }
        let(:dgfip_enrollments) { FactoryGirl.create_list(:enrollment_dgfip, 4) }
        let(:api_entreprise_enrollments) { FactoryGirl.create_list(:enrollment_api_entreprise, 5) }
        before do
          api_particulier_enrollments && api_entreprise_enrollments && dgfip_enrollments
        end

        describe 'with a basic user' do
          let(:user) { FactoryGirl.create(:user) }
          subject { described_class.new(user, relation) }

          it 'returns an empty relation' do
            expect(subject.resolve).to match_array([])
          end
        end

        describe 'with a dgfip user' do
          let(:user) { FactoryGirl.create(:user_dgfip) }
          subject { described_class.new(user, relation) }

          it 'returns dgfip enrollments' do
            expect(subject.resolve).to match_array(dgfip_enrollments)
          end
        end

        describe 'with a user applicant of the dgfip enrollments' do
          let(:user) { FactoryGirl.create(:user) }
          let(:enrollment) { dgfip_enrollments.first }
          subject { described_class.new(user, relation) }
          before do
            user.add_role(:applicant, enrollment)
          end

          it 'returns the enrollment' do
            expect(subject.resolve).to match_array([enrollment])
          end
        end
      end
    end
  end
end
