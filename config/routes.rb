Rails.application.routes.draw do

  namespace :api, path: '', as: '' do
    namespace :v1 do
      resources :spreads, only: [:index, :show]
    end
  end

  # Defines the root path route ("/")
  # root _v1_spreads_path
end
