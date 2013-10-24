module BestBoy
  class MonthReport < ActiveRecord::Base

      # associations
      #
      #

      belongs_to :eventable, polymorphic: true
      belongs_to :month_report

      # validations
      #
      #

      validates :eventable_id, :eventable_type, :event_type, presence: true

      # scopes
      #
      #

      scope :created_on, ->(date) { where('created_at >= ? AND created_at <= ?', date.beginning_of_day, date.end_of_day) }
      scope :month, ->(month, year) { where('created_at >= ? AND created_at <= ?', Date.parse("01."+month.to_s+"."+year.to_s).beginning_of_day,
                                            Date.parse("01."+month.to_s+"."+year.to_s).next_month.beginning_of_day) }

      # instance methods
      #
      #

      delegate :month, :year,  to: :created_at

      def closed?
        self.id == BestBoy::MonthReport.where(eventable_id: eventable_id, eventable_type: eventable_type, event_type: event_type).order('created_at ASC').last.id ? false : true
      end

      # class methods
      #
      #

      def self.current_for(eventable, type)
        month_report = self.for(eventable, type).month(Time.now.month, Time.now.year).last
        month_report.present? ? month_report : self.create_for(eventable, type)
      end

      def self.create_for(eventable, type)
        BestBoy::MonthReport.create(eventable_id: eventable.id, eventable_type: eventable.class.to_param, event_type: type)
      end

      def self.for(eventable, type)
        self.where(eventable_id: eventable.id, eventable_type: eventable.class, event_type: type)
      end
  end
end
