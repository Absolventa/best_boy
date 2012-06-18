Rails.application.routes.draw do |map|
  get "best_boy_admin/stats" => "backend/best_boy_events#stats", :as => :best_boy_admin_stats
  get "best_boy_admin/lists" => "backend/best_boy_events#lists", :as => :best_boy_admin_lists
end