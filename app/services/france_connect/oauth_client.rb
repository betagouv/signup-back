# frozen_string_literal: true

module FranceConnect
  class OauthClient
    attr_reader :me_url
    OMNIAUTH_CONFIG = YAML.load(ERB.new(File.read(Rails.root.join('config/omniauth.yml'))).result)[Rails.env]['france_connect']

    def initialize
      base_url = OMNIAUTH_CONFIG['client_options']['site']
      @me_url = '/oauth/v1/userinfo'

      @conn = Faraday.new(base_url, ssl: { verify: false }) do |conn|
        conn.response :json, content_type: /\bjson$/
        conn.adapter Faraday.default_adapter
      end
    end

    def me(token)
      Rails.cache.fetch(token, expires_in: 10.minutes) do
        res = @conn.get do |req|
          req.url me_url
          req.headers['Authorization'] = "Bearer #{token}"
        end

        raise AccessDenied, res.body unless res.success?

        res.body['user']
      end
    rescue StandardError => e
      raise AccessDenied, e.message
    end
  end

  class AccessDenied < StandardError; end
end
