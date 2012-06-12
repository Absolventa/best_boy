module BestBoy
  class BestBoyEvent < ActiveRecord::Base
    belongs_to :owner, :polymorphic => true
    attr_accessible :owner_id, :owner_type, :event
  end
end