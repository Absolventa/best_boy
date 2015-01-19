module BestBoy
  class DayReport < ActiveRecord::Base

    include BestBoy::ObeysTestMode

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

    def self.current_or_create_for(owner, type, source = nil, date = Time.zone.now)
      day_report = self.current_for(date, owner, type, source).last
      day_report.present? ? day_report : self.create_for(owner, type, source, date)
    end

    def self.create_for(owner, type, source = nil, date = Time.zone.now)
      month_report = BestBoy::MonthReport.current_or_create_for(owner, type, source, date)
      day_report   = BestBoy::DayReport.new

      day_report.owner_type      = owner
      day_report.event           = type
      day_report.month_report_id = month_report.id
      day_report.event_source    = source
      day_report.created_at      = date

      day_report.save ? day_report : nil
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
