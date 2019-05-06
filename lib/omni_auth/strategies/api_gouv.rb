require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class ApiGouv < OmniAuth::Strategies::OAuth2
      option :name, :api_gouv

      option :client_options, {
        site: ENV['OAUTH_HOST'],
        authorize_url: '/oauth/authorize',
        auth_scheme: :basic_auth,
        ssl: {
          verify: false # TODO verify it in production env
        }
      }
      option :scope, 'openid email roles'

      uid {raw_info['sub']}

      info do
        raw_info
      end

      def raw_info
        @raw_info ||= access_token.get('/oauth/userinfo').parsed
      end

      def callback_url
        "#{ENV['BACK_HOST']}/users/auth/api_gouv/callback"
      end

      # forward source page param to display a contextualised login page on api-auth
      def authorize_params
        super.merge(source: request.params["source"])
      end
    end
  end
end
