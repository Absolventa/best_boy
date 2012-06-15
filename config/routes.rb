Rails.application.routes.draw do |map|
  get "best_boy_admin" => "backend/best_boy_events#stats", :as => :best_boy_admin
end