class BestBoyEvent < ActiveRecord::Base

  # associations
  #
  #
  belongs_to :owner, :polymorphic => true

  # validations
  #
  #
  validates :event, :presence => true

end
