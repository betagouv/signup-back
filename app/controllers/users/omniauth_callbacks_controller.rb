module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    FRONT_CONFIG = YAML.load_file(Rails.root.join('config/front.yml'))[Rails.env]

    def oauth2_callback
      token = request.env['omniauth.auth']['credentials'].token
      redirect_to "#{FRONT_CONFIG['callback_url']}/#{token}"
    end

    alias dgfip oauth2_callback
    alias france_connect oauth2_callback

    def passthru
      render status: :bad_request, json: {
        message: 'authentification provider not supported'
      }
    end

    def failure
      render status: :unauthorized, json: {
        message: 'you are not authorized to access this api'
      }
    end

    protected

    def after_omniauth_failure_path_for(_scope)
      users_access_denied_path
    end
  end
end
