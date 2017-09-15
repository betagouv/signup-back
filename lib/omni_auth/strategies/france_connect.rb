require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class FranceConnect < OmniAuth::Strategies::OAuth2
      # change the class name and the :name option to match your application name
      option :name, :france_connect

      option :client_options, site: 'http://localhost:3001',
                              authorize_url: '/oauth/authorize'

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
        full_host + script_name + callback_path
      end
    end
  end
end
