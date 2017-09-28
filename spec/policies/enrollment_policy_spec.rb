require 'rails_helper'

RSpec.describe EnrollmentPolicy do
  subject { described_class }

  permissions :create? do
    let(:user) { FactoryGirl.create(:user) }
    let(:fc_user) { FactoryGirl.create(:user, provider: 'france_connect') }
    let(:enrollment) { FactoryGirl.create(:enrollment) }

    it 'deny access if not france_connected_user' do
      expect(subject).not_to permit(user, enrollment)
    end

    it 'allow access if france_connected_user' do
      expect(subject).to permit(fc_user, enrollment)
    end
  end

  permissions :update? do
    let(:user) { FactoryGirl.create(:user) }
    let(:fc_user) { FactoryGirl.create(:user, provider: 'france_connect') }
    let(:enrollment) { FactoryGirl.create(:enrollment) }

    it 'deny access if not france_connected_user' do
      expect(subject).not_to permit(user, enrollment)
    end

    it 'deny access if france_connected_user and cannot complete application' do
      expect(enrollment).to receive(:can_complete_application?).and_return(false)
      expect(subject).not_to permit(fc_user, enrollment)
    end

    it 'allow access if france_connected_user and can complete application' do
      expect(enrollment).to receive(:can_complete_application?).and_return(true)
      expect(subject).to permit(fc_user, enrollment)
    end
  end
end
