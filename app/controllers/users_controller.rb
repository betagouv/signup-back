class UsersController < ApplicationController
  before_action :authenticate_user!

  def me
    user = current_user.attributes
    render json: user.as_json
  end

  def join_organization
    # we clear signup session here to trigger organization sync with api-auth
    session.delete("access_token")
    session.delete("id_token")
    sign_out current_user
    redirect_to "#{ENV.fetch("OAUTH_HOST")}/users/join-organization"
  end
end
