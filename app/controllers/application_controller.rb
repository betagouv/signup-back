# frozen_string_literal: true

class ApplicationController < ActionController::Base
  attr_reader :client, :current_user

  include Pundit

  protect_from_forgery with: :null_session

  rescue_from 'ResourceProvider::AccessDenied' do |e|
    render status: :unauthorized, json: {
      message: "Vous n'êtes pas authorisé à accéder à cette API",
      detail: e.message
    }
  end

  rescue_from 'FranceConnect::AccessDenied' do |e|
    render status: :unauthorized, json: {
      message: "Vous n'êtes pas authorisé à accéder à cette API",
      detail: e.message
    }
  end

  rescue_from Pundit::NotAuthorizedError do |_|
    render status: :forbidden, json: {
      message: ["Vous n'êtes pas authorisé à modifier cette ressource"]
    }
  end

  rescue_from ActiveRecord::RecordNotFound do |_|
    render status: :not_found, json: {
      message: 'Record not found'
    }
  end

  private

  def authenticate!
    @current_user ||= User.find_by(uid: oauth_user['uid'].to_s)
    raise ResourceProvider::AccessDenied, 'User not found' unless current_user
  end

  def oauth_user
    token = authorization_header.gsub(/Bearer /, '')

    # Rails.cache.fetch(token, expires_in: 10.minutes) do
      client.me(token)
    # end
  end

  def authorization_header
    res = request.headers['Authorization'] || session_bearer
    raise ResourceProvider::AccessDenied, 'You must privide an authorization header' unless res
    res
  end

  def session_bearer
    "Bearer #{session[:token]}" if session[:token]
  end

  def client
    oauth_provider = request.headers['X-Oauth-Provider'] || session[:oauth_provider] || 'resourceProvider'
    @client ||= Object.const_get("#{oauth_provider.classify}::OauthClient").new
  end
end
