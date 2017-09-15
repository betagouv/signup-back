require 'oauth2'

class ApplicationController < ActionController::Base
  attr_reader :client
  protect_from_forgery with: :null_session

  rescue_from Dgfip::AccessDenied do |_e|
    redirect_to(users_access_denied_path)
  end

  private

  def authenticate!
    token = authorization_header.gsub(/Bearer /, '')

    oauth_user = Rails.cache.fetch(token, expires_in: 10.minutes) do
      client.me(token)
    end

    current_user = User.find_by(uid: oauth_user['id'])
    raise Dgfip::AccessDenied unless current_user
  end

  def authorization_header
    res = request.headers['Authorization']
    raise Dgfip::AccessDenied unless res
    res
  end

  def client
    @client ||= Dgfip::OauthClient.new
  end
end
