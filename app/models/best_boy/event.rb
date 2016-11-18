# frozen_string_literal: true
module BestBoy
  class Event < ActiveRecord::Base

    include BestBoy::ObeysTestMode

    # db configuration
    #
    #

    self.table_name = "best_boy_events"

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
end
