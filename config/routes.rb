Rails.application.routes.draw do
  scope :api do
    resources :enrollments do
      collection do
        get :public
        get :user
      end
      member do
        patch :trigger
        post :copy
        get :copies
        get :next_enrollments
      end
    end

    get "/users/me", to: "users#me"
    get "/users/join-organization", to: "users#join_organization"
    devise_scope :user do
      get "/users/sign_out", to: "users/sessions#destroy", as: :destroy_user_session
    end

    resources :users do
      collection do
      end
    end

    get "/stats", to: "stats#show"
    get "/stats/majority_percentile_processing_time_in_days", to: "stats#majority_percentile_processing_time_in_days"

    get "/events/most-used-comments", to: "events#most_used_comments"

    post "/sendinblue-webhooks/rgpd-contact-error/:capability_url_id",
      to: "sendinblue_webhooks#rgpd_contact_error",
      constraints: {capability_url_id: /[A-Za-z0-9]{64}/}

    get "/insee-proxy/naf/:id", to: "insee_proxy#naf", id: /\d{2}\.\d{2}[A-Z]/
  end

  devise_scope :api do
    devise_for :users, controllers: {
      omniauth_callbacks: "users/sessions",
      sessions: "devise/sessions"
    }
  end

  get "/uploads/:model/:type/:mounted_as/:id/:filename", to: "documents#show", constraints: {filename: /[^\/]+/}
end
