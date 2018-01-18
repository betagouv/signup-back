# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  before do
    request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'dgfip calls successfully' do
    let(:token) { '12345' }
    before do
      request.env['omniauth.auth'] = OmniAuth::AuthHash.new(
        credentials: { token: token },
        info: { email: 'user@user.user', roles: ['test'] },
        provider: 'dgfip',
        uid: '123545'
      )
    end

    it 'creates an user' do
      get :resource_provider

      user = User.find_by(email: 'user@user.user')

      expect(user.oauth_roles).to eq(['test'])
    end

    it 'redirects to front host' do
      front_host = YAML.load_file('config/front.yml')[Rails.env]['callback_url']

      get :resource_provider

      expect(response).to redirect_to(Regexp.new(front_host))
    end

    it 'redirects with token' do
      front_host = YAML.load_file('config/front.yml')[Rails.env]['host']

      get :resource_provider

      expect(response).to redirect_to(Regexp.new(token))
    end
  end
end
