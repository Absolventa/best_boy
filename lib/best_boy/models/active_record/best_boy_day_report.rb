module BestBoy
  class DayReport < ActiveRecord::Base

    # associations
    #
    #

    belongs_to :eventable, polymorphic: true
    belongs_to :month_report

    # validations
    #
    #

    validates :month_report_id, :eventable_type, :event_type, presence: true

    # scopes
    #
    #

    scope :created_on, ->(date) { where(created_at: date.beginning_of_day..date.end_of_day) }
    scope :week,       ->       { where(created_at: Time.now.beginning_of_week..Time.now)   }

    # class methods
    #
    #

    def self.current_for(date, eventable, type, source = nil)
      self.for(eventable, type, source).created_on(date)
    end

    def self.current_or_create_for(eventable, type, source = nil)
      day_report = self.current_for(Time.now, eventable, type, source).last
      day_report.present? ? day_report : self.create_for(eventable, type, source)
    end

    def self.create_for(eventable, type, source = nil)
      month_report = BestBoy::MonthReport.current_or_create_for(eventable, type, source)
      BestBoy::DayReport.create(
        eventable_type:  eventable,
        event_type:      type,
        month_report_id: month_report.to_param,
        event_source:    source
      )
    end

    def self.for(eventable, type, source = nil)
      self.where(eventable_type: eventable, event_type: type, event_source: source)
    end

    def self.daily_occurences_for(eventable, type, source = nil)
      self.created_on(Date.today).for(eventable, type, source).sum(:occurences)
    end

    def self.weekly_occurences_for(eventable, type, source = nil)
      self.week.for(eventable, type, source).sum(:occurences)
    end
  end
end
