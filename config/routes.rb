# frozen_string_literal: true

Rails.application.routes.draw do
  scope :api do
    resources :enrollments do
      collection do
        get :public
      end
      member do
        get :convention
        patch :trigger
        patch :update_contacts
      end
    end

    get 'users/access_denied'
  end

  devise_scope :api do
    devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  end

  get '/uploads/:model/:type/:mounted_as/:id/:filename', to: 'documents#show'
end
