module BestBoy
  class DayReport < ActiveRecord::Base

    # db configuration
    #
    #

    self.table_name = "best_boy_day_reports"

    # associations
    #
    #

    belongs_to :owner, polymorphic: true
    belongs_to :month_report

    # validations
    #
    #

    validates :month_report_id, :owner_type, :event, presence: true

    # scopes
    #
    #

    scope :created_on, ->(date) { where(created_at: date.beginning_of_day..date.end_of_day) }
    scope :week,       ->       { where(created_at: Time.zone.now.beginning_of_week..Time.zone.now)   }

    # class methods
    #
    #

    def self.current_for(date, owner, type, source = nil)
      self.for(owner, type, source).created_on(date)
    end

    def self.current_or_create_for(owner, type, source = nil)
      day_report = self.current_for(Time.now, owner, type, source).last
      day_report.present? ? day_report : self.create_for(owner, type, source)
    end

    def self.create_for(owner, type, source = nil)
      month_report = BestBoy::MonthReport.current_or_create_for(owner, type, source)
      BestBoy::DayReport.create(
        owner_type:  owner,
        event:      type,
        month_report_id: month_report.to_param,
        event_source:    source
      )
    end

    def self.for(owner, type, source = nil)
      self.where(owner_type: owner, event: type, event_source: source)
    end

    def self.daily_occurrences_for(owner, type, source = nil, date)
      self.created_on(date).for(owner, type, source).sum(:occurrences)
    end

    def self.weekly_occurrences_for(owner, type, source = nil)
      self.week.for(owner, type, source).sum(:occurrences)
    end
  end
end
