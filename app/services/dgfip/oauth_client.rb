# frozen_string_literal: true

module Dgfip
  class OauthClient
    attr_reader :me_url
    OMNIAUTH_CONFIG = YAML.load_file(Rails.root.join('config/omniauth.yml'))[Rails.env]

    def initialize
      base_url = OMNIAUTH_CONFIG['client_options']['site']
      @me_url = OMNIAUTH_CONFIG['client_options']['me_url']

      @conn = Faraday.new(base_url) do |conn|
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
      res
    rescue StandardError => e
      raise AccessDenied, e.message
    end
  end
end
