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
      end
    end

    get "/stats", to: "stats#show"
    get "/stats/average_processing_time_in_days", to: "stats#average_processing_time_in_days"
    get "/events/most-used-comments", to: "events#most_used_comments"
    get "/users/me", to: "users#me"
    get "/users/join-organization", to: "users#join_organization"

    devise_scope :user do
      get "/users/sign_out", to: "users/sessions#destroy", as: :destroy_user_session
    end
  end

  devise_scope :api do
    devise_for :users, controllers: {
      omniauth_callbacks: "users/sessions",
      sessions: "devise/sessions",
    }
  end

  get "/uploads/:model/:type/:mounted_as/:id/:filename", to: "documents#show", constraints: {filename: /[^\/]+/}
end
