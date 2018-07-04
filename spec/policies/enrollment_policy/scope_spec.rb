require 'rails_helper'

describe EnrollmentPolicy::Scope do
  describe '#resolve' do
    describe 'with Enrollment ActiveRecord::Relation' do
      let(:relation) { Enrollment.all }

      describe 'there are api_particulier and dgfip enrollments in database' do
        let(:api_particulier_enrollments) { create_list(:enrollment_api_particulier, 3) }
        let(:dgfip_enrollments) { create_list(:enrollment_dgfip, 4) }
        before do
          api_particulier_enrollments && dgfip_enrollments
        end

        describe 'with a basic user' do
          let(:user) { create(:user) }
          subject { described_class.new(user, relation) }

          it 'returns an empty relation' do
            expect(subject.resolve).to match_array([])
          end
        end

        describe 'with a api_particulier user' do
          let(:user) { create(:user, provider: 'api_particulier') }
          subject { described_class.new(user, relation) }

          it 'returns api_particulier enrollments' do
            expect(subject.resolve).to match_array(api_particulier_enrollments)
          end
        end

        describe 'with a dgfip user' do
          let(:user) { create(:user, provider: 'dgfip') }
          subject { described_class.new(user, relation) }

          it 'returns dgfip enrollments' do
            expect(subject.resolve).to match_array(dgfip_enrollments)
          end
        end

        describe 'with a user applicant of the api_particulier enrollments' do
          let(:user) { create(:user) }
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

      describe 'there are api_particulier and dgfip enrollments in database' do
        let(:api_particulier_enrollments) { create_list(:enrollment_api_particulier, 3) }
        let(:dgfip_enrollments) { create_list(:enrollment_dgfip, 4) }
        before do
          api_particulier_enrollments && dgfip_enrollments
        end

        describe 'with a basic user' do
          let(:user) { create(:user) }
          subject { described_class.new(user, relation) }

          it 'returns an empty relation' do
            expect(subject.resolve).to match_array([])
          end
        end

        describe 'with a api_particulier user' do
          let(:user) { create(:user, provider: 'api_particulier') }
          subject { described_class.new(user, relation) }

          it 'returns api_particulier enrollments' do
            expect(subject.resolve).to match_array(api_particulier_enrollments)
          end
        end

        describe 'with a user applicant of the api_particulier enrollments' do
          let(:user) { create(:user) }
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

    describe 'with Enrollment::Dgfip ActiveRecord::Relation' do
      let(:relation) { Enrollment::Dgfip.all }

      describe 'there are api_particulier, and dgfip enrollments in database' do
        let(:api_particulier_enrollments) { create_list(:enrollment_api_particulier, 3) }
        let(:dgfip_enrollments) { create_list(:enrollment_dgfip, 4) }
        before do
          api_particulier_enrollments && dgfip_enrollments
        end

        describe 'with a basic user' do
          let(:user) { create(:user) }
          subject { described_class.new(user, relation) }

          it 'returns an empty relation' do
            expect(subject.resolve).to match_array([])
          end
        end

        describe 'with a dgfip user' do
          let(:user) { create(:user, provider: 'dgfip') }
          subject { described_class.new(user, relation) }

          it 'returns dgfip enrollments' do
            expect(subject.resolve).to match_array(dgfip_enrollments)
          end
        end

        describe 'with a user applicant of the dgfip enrollments' do
          let(:user) { create(:user) }
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
