# frozen_string_literal: true

require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class FranceConnect < OmniAuth::Strategies::OAuth2
      # change the class name and the :name option to match your application name
      option :name, :france_connect
      option :client_options, site: 'https://partenaires.dev.dev-franceconnect.fr',
                              authorize_url: '/oauth/v1/authorize',
                              token_url: '/oauth/v1/token',
                              ssl: { verify: false }

      option :scope, 'service-providers user'

      uid { raw_info['id'] }

      info do
        raw_info['user']
      end

      def raw_info
        @raw_info ||= access_token.get('/oauth/v1/userinfo').parsed
      end

      # https://github.com/intridea/omniauth-oauth2/issues/81
      def callback_url
        full_host + script_name + callback_path
      end
    end
  end
end
