Rails.application.routes.draw do
  scope :api do
    resources :enrollments do
      collection do
        get :public
        get :user
      end
      member do
        get :convention
        patch :trigger
      end
    end

    get "/stats", to: "stats#show"
    get "/events/most-used-comments", to: "events#most_used_comments"
    get "/users/me", to: "users#me"
    get "/enrollments/user", to: "enrollments#user"

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
