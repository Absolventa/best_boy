BestBoy::Engine.routes.draw do

  root to: "events#index"

  resources :events, only: [:index] do
    collection do
      get :stats
      get :lists
      get :details
      get :monthly_details
    end
  end
end
