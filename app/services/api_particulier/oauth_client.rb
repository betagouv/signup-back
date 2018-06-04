# frozen_string_literal: true

class ApiParticulier::OauthClient
  attr_reader :me_url
  OMNIAUTH_CONFIG = YAML.load(ERB.new(File.read(Rails.root.join('config/omniauth.yml'))).result)[Rails.env]['resource_provider']

  def initialize
    base_url = OMNIAUTH_CONFIG['client_options']['site']
    @me_url = OMNIAUTH_CONFIG['client_options']['me_url']

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

      raise ApiParticulier::AccessDenied, res.body unless res.success?
      User.from_service_provider_omniauth(res.body)
    end
  rescue StandardError => e
    raise ApiParticulier::AccessDenied, e.message
  end
end
