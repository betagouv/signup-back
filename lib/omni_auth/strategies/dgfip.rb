# frozen_string_literal: true

require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Dgfip < OmniAuth::Strategies::OAuth2
      option :name, :dgfip

      option :client_options, YAML.load_file(Rails.root.join('config/omniauth.yml'))[Rails.env]['client_options']

      uid { raw_info['id'] }

      info do
        {
          email: raw_info['email']
          # and anything else you want to return to your API consumers
        }
      end

      def raw_info
        @raw_info ||= access_token.get('/api/v1/me.json').parsed
      end

      # https://github.com/intridea/omniauth-oauth2/issues/81
      def callback_url
        if Rails.env.production?
          return 'https://impots.particulier.api.gouv.fr/users/auth/dgfip/callback'
        end
        full_host + script_name + callback_path
      end
    end
  end
end
