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
    # We fetch the user from api-auth at each call.
    # This is useful when a user submit a new enrollment while is email is not validated:
    # 1. the user submits the enrollment
    # 2. he gets the error "you must validate your email before submitting"
    # 3. he clicks on the validation link
    # 4. since his profile is reloaded at each call here, he can now submit his enrollment
    #   without logging in and out again
    res = @conn.get do |req|
      req.url me_url
      req.headers['Authorization'] = "Bearer #{token}"
    end

    raise ApplicationController::AccessDenied, res.body unless res.success?
    User.reconcile({info: res.body})
  rescue StandardError => e
    raise ApplicationController::AccessDenied, e.message
  end
end
