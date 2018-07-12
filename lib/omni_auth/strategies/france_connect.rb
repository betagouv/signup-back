# frozen_string_literal: true

require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class FranceConnect < OmniAuth::Strategies::OAuth2
      # change the class name and the :name option to match your application name
      option :name, :france_connect
      option :client_options, YAML.load(ERB.new(File.read(Rails.root.join('config/omniauth.yml'))).result)[Rails.env]['france_connect']['client_options']

      option :scope, 'service-providers user'

      uid { raw_info['id'] }

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
