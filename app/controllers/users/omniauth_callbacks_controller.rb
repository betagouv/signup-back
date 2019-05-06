module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def api_gouv
      token = request.env['omniauth.auth']['credentials'].token
      session[:token] = token
      @current_user = User.reconcile(request.env['omniauth.auth'])
      redirect_to "#{ENV.fetch('OAUTH_REDIRECT_URI')}?token=#{token}"
    end

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
