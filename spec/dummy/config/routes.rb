Rails.application.routes.draw do

  mount BestBoy::Engine => "/best_boy"

  root :to => "test_events#index"
  resources :test_events
end
