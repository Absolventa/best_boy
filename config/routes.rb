BestBoy::Engine.routes.draw do

  root to: "best_boy_events#index"

  resources :best_boy_events, only: [:index] do
    collection do
      get :stats
      get :list
      get :charts
      get :details
      get :monthly_details
    end
  end

  # get "best_boy_admin" => "best_boy/best_boy_events#index", :as => :best_boy_admin
  # get "best_boy_admin/stats" => "best_boy/best_boy_events#stats", :as => :best_boy_admin_stats
  # get "best_boy_admin/lists" => "best_boy/best_boy_events#lists", :as => :best_boy_admin_lists
  # get "best_boy_admin/charts" => "best_boy/best_boy_events#charts", :as => :best_boy_admin_charts
  # get "best_boy_admin/details" => "best_boy/best_boy_events#details", :as => :best_boy_admin_details
  # get "best_boy_admin/monthly_details" => "best_boy/best_boy_events#monthly_details", :as => :best_boy_admin_monthly_details
end