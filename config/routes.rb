Rails.application.routes.draw do

  namespace :api, path: '', as: '' do
    namespace :v1 do
      resources :spreads, only: [:index, :show]
    end

    root to: 'v1/spreads#index'
  end
end
