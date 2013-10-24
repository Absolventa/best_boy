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

      validates :month_report_id, :eventable_id, :eventable_type, :event_type, presence: true

      # scopes
      #
      #

      scope :created_on, ->(date) { where('created_at >= ? AND created_at <= ?', date.beginning_of_day, date.end_of_day) }

      # instance methods
      #
      #

      delegate :day, :month, :year, to: :created_at

      def closed?
        self.id == BestBoy::DayReport.where(eventable_id: eventable_id, eventable_type: eventable_type, event_type: event_type).order('created_at ASC').last.id ? false : true
      end

      # class methods
      #
      #

      def self.current_for(eventable, type)
        day_report = self.for(eventable, type).today.last
        day_report.present? ? day_report : self.create_for(eventable, type)
      end

      def self.create_for(eventable, type)
        month_report = BestBoy::MonthReport.current_for(eventable, type)
        day_report = BestBoy::DayReport.create(eventable_id: eventable.id, eventable_type: eventable.class.to_param, event_type: type, month_report_id: month_report.to_param)
        day_report
      end

      def self.for(eventable, type)
        self.where(eventable_id: eventable.id, eventable_type: eventable.class, event_type: type)
      end

      def self.today
        self.created_on(Date.today)
      end

      def self.yesterday
        self.created_on(Date.yesterday)
      end
  end
end
