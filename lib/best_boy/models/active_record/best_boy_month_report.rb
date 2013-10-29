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

    scope :created_on, ->(date) { where('created_at >= ? AND created_at <= ?', date.beginning_of_day, date.end_of_day) }

    scope :months, ->(start_month, end_month, start_year, end_year) {
      where('created_at >= ? AND created_at < ?',
            Date.parse("#{start_year}-#{start_month}-01").beginning_of_day,
            Date.parse("#{end_year}-#{end_month}-01").next_month.beginning_of_day
      )
    }

    scope :month, ->(month, year) {
      where('created_at >= ? AND created_at < ?',
            Date.parse("#{year}-#{month}-01").beginning_of_day,
            Date.parse("#{year}-#{month}-01").next_month.beginning_of_day
      )
    }

    # instance methods
    #
    #

    delegate :month, :year, to: :created_at

    def closed?
      self.id == BestBoy::MonthReport.where(eventable_type: eventable_type, event_type: event_type, event_source: event_source).order('created_at ASC').last.id ? false : true
    end

    # class methods
    #
    #

    def self.current_for(eventable, type, source = nil)
      if source.present?
        month_report = self.for(eventable, type, source).month(Time.now.month, Time.now.year).last
      else
        month_report = self.for(eventable, type).month(Time.now.month, Time.now.year).last
      end
      month_report.present? ? month_report : self.create_for(eventable, type)
    end

    def self.create_for(eventable, type, source = nil)
      if source.present?
        BestBoy::MonthReport.create(eventable_type: eventable.to_s, event_type: type, event_source: source)
      else
        BestBoy::MonthReport.create(eventable_type: eventable.to_s, event_type: type)
      end
    end

    def self.for(eventable, type, source = nil)
      self.where(eventable_type: eventable, event_type: type, event_source: source)
    end
  end
end
