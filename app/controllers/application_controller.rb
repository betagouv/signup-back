# frozen_string_literal: true

class ApplicationController < ActionController::Base
  attr_reader :client, :current_user

  include Pundit

  protect_from_forgery with: :null_session

  rescue_from Dgfip::AccessDenied do |e|
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
    @current_user ||= User.find_by(uid: oauth_user['id'].to_s)
    raise Dgfip::AccessDenied, 'User not found' unless current_user
  end

  def oauth_user
    token = authorization_header.gsub(/Bearer /, '')

    if Rails.env.docker? || Rails.env.production?
      { 'id' => token }
    else
      Rails.cache.fetch(token, expires_in: 10.minutes) do
        client.me(token)
      end.body
    end
  end

  def authorization_header
    res = request.headers['Authorization'] || session_bearer
    raise Dgfip::AccessDenied, 'You must privide an authorization header' unless res
    res
  end

  def session_bearer
    "Bearer #{session[:token]}" if session[:token]
  end

  def client
    @client ||= Dgfip::OauthClient.new
  end
end
