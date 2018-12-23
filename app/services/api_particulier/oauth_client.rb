# frozen_string_literal: true

class ApiParticulier::OauthClient
  attr_reader :me_url

  def initialize
    base_url = ENV['OAUTH_HOST']
    @me_url = '/oauth/userinfo'

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

      raise ApplicationController::AccessDenied, res.body unless res.success?
      User.from_service_provider_omniauth({info: res.body})
    end
  rescue StandardError => e
    raise ApplicationController::AccessDenied, e.message
  end
end
