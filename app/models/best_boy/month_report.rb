# frozen_string_literal: true
module BestBoy
  class MonthReport < ActiveRecord::Base

    include BestBoy::ObeysTestMode
    include BestBoy::Reporting

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

      def create_for(owner, type, source = nil, date = Time.zone.now)
        month_report              = BestBoy::MonthReport.new
        month_report.owner_type   = owner.to_s
        month_report.event        = type
        month_report.event_source = source
        month_report.created_at   = date || Time.zone.now

        month_report.save ? month_report : nil
      end

      def monthly_occurrences_for(owner, type, source = nil, date)
        MonthReport.for(owner, type, source).between(date.beginning_of_month, date.end_of_month).sum(:occurrences)
      end

      def yearly_occurrences_for(owner, type, source = nil, date)
        MonthReport.for(owner, type, source).between(date.beginning_of_year, date).sum(:occurrences)
      end

      def overall_occurrences_for(owner, type, source = nil)
        MonthReport.for(owner, type, source).sum(:occurrences)
      end
    end
  end
end
