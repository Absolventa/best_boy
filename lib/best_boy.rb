require "active_record"
require "best_boy/instance_methods.rb"
require "best_boy/best_boy_event.rb"

module BestBoy
  def has_a_best_boy
    include InstanceMethods
    has_many :best_boy_events, :as => :owner, :dependent => :nullify
    after_create :trigger_create_event
    before_destroy :trigger_destroy_event
  end
end

ActiveRecord::Base.send :extend, BestBoy