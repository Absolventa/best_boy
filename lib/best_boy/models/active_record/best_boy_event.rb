class BestBoyEvent < ActiveRecord::Base
    # associations
    #
    #
    belongs_to :owner, :polymorphic => true
    
    # validations
    #
    #
    validates :event, :presence => true
    
    # attributes
    #
    #
    attr_accessible :owner_id, :owner_type, :event
  
  end