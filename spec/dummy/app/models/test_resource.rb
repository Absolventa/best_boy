class TestResource < ActiveRecord::Base
  include BestBoy::Eventable
  has_a_best_boy
end
