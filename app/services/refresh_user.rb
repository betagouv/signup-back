class RefreshUser < ApplicationService
  def initialize(access_token)
    @access_token = access_token
  end

  def call
    response = Http.get(
      "#{ENV.fetch("OAUTH_HOST")}/oauth/userinfo",
      {"Authorization" => "Bearer #{@access_token}"}
    )

    if response.code != "200"
      raise "Error when refreshing user data. Error message was: #{response.read_body} (#{response.code})"
    end

    User.reconcile(JSON.parse(response.body))
  end
end
