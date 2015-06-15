module BestBoy
  class DayReport < ActiveRecord::Base

    include BestBoy::ObeysTestMode
    include BestBoy::Reporting

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

    class << self

      def create_for(owner, type, source = nil, date = Time.zone.now)
        month_report = BestBoy::MonthReport.current_or_create_for(owner, type, source, date)
        day_report   = BestBoy::DayReport.new

        day_report.owner_type      = owner
        day_report.event           = type
        day_report.month_report_id = month_report.id
        day_report.event_source    = source
        day_report.created_at      = date

        day_report.save ? day_report : nil
      end

      def daily_occurrences_for(owner, type, source = nil, date)
        created_on(date).for(owner, type, source).sum(:occurrences)
      end

      def weekly_occurrences_for(owner, type, source = nil)
        week.for(owner, type, source).sum(:occurrences)
      end
    end
  end
end
