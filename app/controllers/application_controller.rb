require 'oauth2'

class ApplicationController < ActionController::Base
  attr_reader :client, :current_user

  include Pundit

  protect_from_forgery with: :null_session

  rescue_from Dgfip::AccessDenied do |e|
    render status: :unauthorized, json: {
      message: 'you are not authorized to access this API',
      detail: e.message
    }
  end

  rescue_from Pundit::NotAuthorizedError do |e|
    render status: :forbidden, json: {
      message: 'you are not authorized to access this resource',
      detail: e.message
    }
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    render status: :not_found, json: {
      message: 'Record not found'
    }
  end

  private

  def authenticate!
    token = authorization_header.gsub(/Bearer /, '')

    oauth_user = Rails.cache.fetch(token, expires_in: 10.minutes) do
      client.me(token)
    end.body

    @current_user = User.find_by(uid: oauth_user['id'].to_s)
    raise Dgfip::AccessDenied, 'User not found' unless current_user
  end

  def authorization_header
    res = request.headers['Authorization']
    raise Dgfip::AccessDenied, 'You must privide an authorization header' unless res
    res
  end

  def client
    @client ||= Dgfip::OauthClient.new
  end
end
