module BestBoy
  class MonthReport < ActiveRecord::Base

    include BestBoy::ObeysTestMode

    # db configuration
    #
    #

    self.table_name = "best_boy_month_reports"

    # associations
    #
    #

    belongs_to :owner, polymorphic: true
    has_many :day_reports

    # validations
    #
    #

    validates :owner_type, :event, presence: true

    # scopes
    #
    #

    scope :created_on, ->(date)                 { where(created_at: date.beginning_of_day..date.end_of_day) }
    scope :between,    ->(start_date, end_date) { where(created_at: start_date.beginning_of_day..end_date.end_of_day) }

    # class methods
    #
    #

    class << self

      def current_for(date, owner, type, source = nil)
        MonthReport.for(owner, type, source).between(date.beginning_of_month, date)
      end

      def current_or_create_for(owner, type, source = nil, date = Time.zone.now)
        month_report = current_for(Time.zone.now, owner, type, source).last
        month_report.present? ? month_report : create_for(owner, type, source)
      end

      def create_for(owner, type, source = nil, date = Time.zone.now)
        month_report = BestBoy::MonthReport.new
        month_report.owner_type   = owner.to_s
        month_report.event        = type
        month_report.event_source = source
        month_report.created_at   = date || Time.zone.now

        month_report.save ? month_report : nil
      end

      def for(owner, type, source = nil)
        where(owner_type: owner, event: type, event_source: source)
      end

      def monthly_occurrences_for(owner, type, source = nil, date)
        MonthReport.for(owner, type, source).between(date.beginning_of_month, date.end_of_month).sum(:occurrences)
      end

      def self.yearly_occurrences_for(owner, type, source = nil, date)
        MonthReport.for(owner, type, source).between(date.beginning_of_year, date).sum(:occurrences)
      end

      def self.overall_occurrences_for(owner, type, source = nil)
        MonthReport.for(owner, type, source).sum(:occurrences)
      end
    end
  end
end
