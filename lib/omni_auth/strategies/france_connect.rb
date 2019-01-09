# frozen_string_literal: true

require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class FranceConnect < OmniAuth::Strategies::OAuth2
      option :name, :france_connect

      option :client_options, {
        site: ENV['FRANCECONNECT_PARTENAIRES_HOST'],
        authorize_url: '/oauth/v1/authorize',
        token_url: '/oauth/v1/token',
        ssl: {
          verify: false # TODO verify it in production env
        }
      }

      option :scope, 'service-providers user'

      uid {raw_info['id']}

      info do
        raw_info['user']
      end

      def raw_info
        @raw_info ||= access_token.get('/oauth/v1/userinfo').parsed
      end

      def callback_url
        "#{ENV['BACK_HOST']}/users/auth/france_connect/callback"
      end
    end
  end
end
