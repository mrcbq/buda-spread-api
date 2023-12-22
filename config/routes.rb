Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  namespace :api do
    namespace :v1 do
      resources :spreads, only: [:index, :show] do        
        member do
          post 'create_alert'
          get 'poll_alert'
        end
      end
    end
  end

  root to: 'v1/spreads#index'
end