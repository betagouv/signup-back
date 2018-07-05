# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'with an user' do
    let(:user) { create(:user) }

    %w[service_provider france_connect dgfip api_particulier].each do |provider|
      describe "with a #{provider} provider" do
        subject { create(:user, provider: provider) }

        it "is a #{provider}" do
          expect(subject.send("#{provider}?")).to be_truthy
        end

        other_providers = %w[service_provider france_connect dgfip api_particulier]
        other_providers.delete(provider)
        other_providers.each do |other_provider|
          it "is not a #{other_provider}" do
            expect(subject.send("#{other_provider}?")).to be_falsey
          end
        end
      end
    end

    describe 'with an enrollment' do
      let(:enrollment) { create(:enrollment) }

      it 'user can be applicant to an enrollment' do
        user.add_role(:applicant, enrollment)

        expect(user.has_role?(:applicant, enrollment)).to be_truthy
      end
    end

    describe '#self.from_service_provider_omniauth' do
      subject { described_class }

      describe 'There is a service_provider user in database' do
        let(:in_database_data) do
          OmniAuth::AuthHash.new(
            credentials: { token: 'service_provider' },
            'account_type' => 'service_provider',
            'uid' => 'service_provider',
            provider: 'service_provider'
          )
        end
        let(:not_in_database_data) do
          OmniAuth::AuthHash.new(
            credentials: { token: 'service_provider' },
            'account_type' => 'service_provider',
            'uid' => '666',
            'email' => 'not_in_database@service_provider.user'
          )
        end
        let(:user) do
          create(
            :user,
            provider: 'service_provider',
            uid: 'service_provider'
          )
        end
        before do
          user
        end

        it 'returns the user given valid data' do
          current_user = subject.from_service_provider_omniauth(in_database_data)

          expect(current_user).to eq(user)
        end

        it 'creates an user if not exists' do
          expect do
            subject.from_service_provider_omniauth(not_in_database_data)
          end.to change(User, :count).by(1)
        end

        it 'the created user match given data' do
          current_user = subject.from_service_provider_omniauth(not_in_database_data)

          expect(current_user.email).to eq(not_in_database_data['email'])
          expect(current_user.uid).to eq(not_in_database_data['uid'])
          expect(current_user.provider).to eq(not_in_database_data['account_type'])
        end
      end
    end

    describe '#self.from_france_connect_omniauth' do
      subject { described_class }

      describe 'There is a france_connect user in database' do
        let(:user) do
          create(
            :user,
            provider: 'france_connect',
            uid: 'france_connect',
            'email' => 'test@france_connect.user'
          )
        end
        before do
          user
        end
        let(:in_database_data) do
          OmniAuth::AuthHash.new(
            credentials: { token: 'france_connect' },
            info: {
              'uid' => 'france_connect',
              'email' => 'test@france_connect.user'
            },
            provider: 'france_connect'
          )
        end
        let(:not_in_database_data) do
          OmniAuth::AuthHash.new(
            credentials: { token: 'france_connect' },
            info: {
              'uid' => 'france_connect_not_in_database',
              'email' => 'not_in_database@france_connect.user'
            },
            provider: 'france_connect'
          )
        end

        it 'returns the user given valid data' do
          current_user = subject.from_france_connect_omniauth(in_database_data)

          expect(current_user).to eq(user)
        end

        it 'creates an user if not exists' do
          expect do
            subject.from_france_connect_omniauth(not_in_database_data)
          end.to change(User, :count).by(1)
        end

        it 'the created user match given data' do
          current_user = subject.from_france_connect_omniauth(not_in_database_data)

          expect(current_user.email).to eq(not_in_database_data.info['email'])
          expect(current_user.uid).to eq(not_in_database_data.info['uid'])
          expect(current_user.provider).to eq(not_in_database_data['provider'])
        end
      end
    end
  end
end
