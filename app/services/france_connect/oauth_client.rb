# frozen_string_literal: true

module FranceConnect
  class OauthClient
    attr_reader :me_url

    def initialize
      base_url = 'https://partenaires.dev.dev-franceconnect.fr'
      @me_url = '/oauth/v1/userinfo'

      @conn = Faraday.new(base_url, ssl: { verify: false }) do |conn|
        conn.response :json, content_type: /\bjson$/
        conn.adapter Faraday.default_adapter
      end
    end

    def me(token)
      res = @conn.get do |req|
        req.url me_url
        req.headers['Authorization'] = "Bearer #{token}"
      end

      raise AccessDenied, res.body unless res.success?
      res.body['user']
    rescue StandardError => e
      raise AccessDenied, e.message
    end
  end

  class AccessDenied < StandardError; end
end
