Rails.application.routes.draw do
  scope :api do
    get 'users/access_denied'
  end

  devise_scope :api do
    devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
