module BestBoy
  class MonthReport < ActiveRecord::Base

    # associations
    #
    #

    belongs_to :eventable, polymorphic: true
    has_many :day_reports

    # validations
    #
    #

    validates :eventable_type, :event_type, presence: true

    # scopes
    #
    #

    scope :created_on, ->(date)                 { where(created_at: date.beginning_of_day..date.end_of_day) }
    scope :between,    ->(start_date, end_date) { where(created_at: start_date.beginning_of_day..end_date.end_of_day) }
    scope :month,      ->(month, year)          { where(created_at: Date.parse("#{year}-#{month}-01").beginning_of_day..Date.parse("#{year}-#{month}-01").next_month.beginning_of_day) }

    # class methods
    #
    #

    def self.current_for(eventable, type, source = nil)
      month_report = self.for(eventable, type, source).month(Time.now.month, Time.now.year).last
      month_report.present? ? month_report : self.create_for(eventable, type)
    end

    def self.create_for(eventable, type, source = nil)
      BestBoy::MonthReport.create(eventable_type: eventable.to_s, event_type: type, event_source: source)
    end

    def self.for(eventable, type, source = nil)
      self.where(eventable_type: eventable, event_type: type, event_source: source)
    end
  end
end
