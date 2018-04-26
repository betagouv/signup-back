# frozen_string_literal: true

Rails.application.routes.draw do
  scope :api do
    resources :resource_providers, only: %i[index show]
    resources :enrollments do
      resources :messages
      member do
        get :convention
        patch :trigger
      end
    end

    namespace :enrollment do
      resources :dgfips do
        member do
          get :convention
          patch :trigger
        end
      end
    end

    get 'users/access_denied'
  end

  devise_scope :api do
    devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  end

  get '/uploads/:model/:type/:mounted_as/:id/:filename', to: 'documents#show'
end
