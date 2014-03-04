class BestBoyEvent < ActiveRecord::Base

  # associations
  #
  #
  belongs_to :owner, polymorphic: true

  # validations
  #
  #
  validates :event, presence: true

  # scopes
  #
  #

  scope :per_day, ->(date) { where(created_at: date.beginning_of_day..date.end_of_day ) }

end
