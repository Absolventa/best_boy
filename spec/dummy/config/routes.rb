Rails.application.routes.draw do
  root :to => "test_events#index"
  resources :test_events
end
