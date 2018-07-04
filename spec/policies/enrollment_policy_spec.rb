# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EnrollmentPolicy do
  subject { described_class }

  permissions :create? do
    let(:user) { create(:user) }
    let(:service_provider_user) { create(:user, provider: 'service_provider') }
    let(:enrollment) { create(:enrollment) }

    it 'deny access if not service_provider' do
      expect(subject).not_to permit(user, enrollment)
    end

    it 'allow access if service_provider' do
      expect(subject).to permit(service_provider_user, enrollment)
    end
  end

  permissions :update? do
    let(:user) { create(:user) }
    let(:service_provider_user) { create(:user, provider: 'service_provider') }
    let(:enrollment) { create(:enrollment) }

    it 'deny access if not service_provider' do
      expect(subject).not_to permit(user, enrollment)
    end

    describe 'user is applicant of enrollment' do
      before do
        user.add_role(:applicant, enrollment)
      end

      it 'allow access' do
        expect(subject).to permit(user, enrollment)
      end
    end
  end
end
