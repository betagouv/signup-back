class UsersController < ApplicationController
  def access_denied
    render status: :unauthorized, json: {
      message: 'access denied'
    }
  end
end
