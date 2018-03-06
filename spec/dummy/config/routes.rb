Rails.application.routes.draw do

  mount BestBoy::Engine => "/best_boy"

  root to: "test_resources#index"
  resources :test_resources
end
