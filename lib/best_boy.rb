require "active_record"
require "best_boy/instance_methods.rb"
require "best_boy/best_boy_event.rb"

module BestBoy
  def has_a_best_boy
    include InstanceMethods
    has_many :best_boy_events, :as => :owner
    after_create self.create_best_boy_events("create")
    before_destroy self.create_best_boy_events("destroy")
  end
end

ActiveRecord::Base.send :extend, BestBoy