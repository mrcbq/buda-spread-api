Rails.application.routes.draw do

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