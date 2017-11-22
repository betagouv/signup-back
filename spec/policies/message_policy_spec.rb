# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessagePolicy do
  subject { described_class }
  let(:user) { FactoryGirl.create(:user, email: 'user') }
  let(:dgfip_user) { FactoryGirl.create(:user, provider: 'dgfip', email: 'dgfip') }
  let(:france_connect_user) { FactoryGirl.create(:user, provider: 'france_connect', email: 'france_connect') }
  let(:enrollment) { FactoryGirl.create(:enrollment) }
  let(:message) { FactoryGirl.create(:message, enrollment: enrollment) }

  permissions :create? do
    it 'deny access with no user' do
      expect(subject).not_to permit(nil, message)
    end

    it 'allow access for any' do
      expect(subject).to permit(user, message)
    end
  end

  permissions :update? do
    it 'no one can update a message' do
      expect(subject).not_to permit(user, enrollment)
      expect(subject).not_to permit(dgfip_user, enrollment)
      expect(subject).not_to permit(france_connect_user, enrollment)
    end
  end
end
