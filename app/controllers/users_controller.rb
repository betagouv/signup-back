class UsersController < ApplicationController
  before_action :authenticate_user!

  def me
    user = current_user.attributes
    user[:organizations] = session[:user_organizations]
    render json: user.as_json
  end
end
