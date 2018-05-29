# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'with an user' do
    let(:user) { FactoryGirl.create(:user) }

    %w[service_provider france_connect dgfip api_particulier api_entreprise].each do |provider|
      describe "with a #{provider} provider" do
        subject { FactoryGirl.create(:user, provider: provider) }

        it "is a #{provider}" do
          expect(subject.send("#{provider}?")).to be_truthy
        end

        other_providers = %w[service_provider france_connect dgfip api_particulier api_entreprise]
        other_providers.delete(provider)
        other_providers.each do |other_provider|
          it "is not a #{other_provider}" do
            expect(subject.send("#{other_provider}?")).to be_falsey
          end
        end
      end
    end

    describe 'with an enrollment' do
      let(:enrollment) { FactoryGirl.create(:enrollment) }

      it 'user can be applicant to an enrollment' do
        user.add_role(:applicant, enrollment)

        expect(user.has_role?(:applicant, enrollment)).to be_truthy
      end
    end

    describe "#self.from_service_provider_omniauth" do
      subject { described_class }

      describe 'There is a service_provider user in database' do
        let(:valid_data) { { 'account_type' => 'service_provider', 'uid' => '12' } }
        let(:invalid_data) { { 'account_type' => 'service_provider', 'uid' => '666', 'email' => 'invalid@user.user' } }
        let(:user) { FactoryGirl.create(:user, provider: 'service_provider', uid: '12') }
        before do
          user
        end

        it 'returns the user given valid data' do
          current_user = subject.from_service_provider_omniauth(valid_data)

          expect(current_user).to eq(user)
        end

        it 'creates an user if not exists' do
          expect do
            subject.from_service_provider_omniauth(invalid_data)
          end.to change(User, :count).by(1)
        end

        it 'the created user match given data' do
          current_user = subject.from_service_provider_omniauth(invalid_data)

          expect(current_user.email).to eq(invalid_data['email'])
          expect(current_user.uid).to eq(invalid_data['uid'])
          expect(current_user.provider).to eq(invalid_data['account_type'])
        end
      end
    end
  end
end
