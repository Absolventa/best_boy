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

    def self.current_for(date, eventable, type, source = nil)
      self.for(eventable, type, source).month(date.month, date.year)
    end

    def self.current_or_create_for(eventable, type, source = nil)
      month_report = self.current_for(Time.now, eventable, type, source).last
      month_report.present? ? month_report : self.create_for(eventable, type, source)
    end

    def self.create_for(eventable, type, source = nil)
      BestBoy::MonthReport.create(eventable_type: eventable.to_s, event_type: type, event_source: source)
    end

    def self.for(eventable, type, source = nil)
      self.where(eventable_type: eventable, event_type: type, event_source: source)
    end

    def self.monthly_occurences_for(eventable, type, source, date)
      self.for(eventable, type, source).between(date.beginning_of_month, date.end_of_month).sum(:occurences)
    end

    def self.yearly_occurences_for(eventable, type, source, date)
      self.for(eventable, type, source).between(date.beginning_of_year, date).sum(:occurences)
    end

    def self.overall_occurences_for(eventable, type, source)
      self.for(eventable, type, source).sum(:occurences)
    end
  end
end
