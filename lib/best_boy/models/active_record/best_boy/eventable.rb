module BestBoy
  module Eventable
    extend ActiveSupport::Concern

    module ClassMethods
      attr_accessor :disable_callbacks
      @disable_callbacks = nil

      def has_a_best_boy(options={})
        # constants
        #
        #
        @disable_callbacks = options[:disable_callbacks]

        # associations
        #
        #
        has_many :best_boy_events, :as => :owner, :dependent => :nullify

        # callbacks
        #
        #
        after_create :trigger_create_event
        after_destroy :trigger_destroy_event
      end

      def best_boy_disable_callbacks
        @disable_callbacks
      end
    end

    def eventable?
      true
    end

    def trigger_create_event
      return if self.class.best_boy_disable_callbacks
      create_best_boy_event_with_type "create"
    end

    def trigger_destroy_event
      return if self.class.best_boy_disable_callbacks
      create_best_boy_event_with_type "destroy"
    end

    def trigger_best_boy_event type, source = nil
      create_best_boy_event_with_type(type, source)
    end

    def create_best_boy_event_with_type type, source = nil
      raise "nil event is not allowed" if type.blank?
      best_boy_event = BestBoyEvent.new(:event => type, :event_source => source)
      best_boy_event.owner = self
      best_boy_event.save
      report type
    end

    def report type
      @month_report = BestBoy::MonthReport.current_for(self.class.to_s, type)
      @day_report   = BestBoy::DayReport.current_for(self.class.to_s, type)

      increment_occurences_in_month_report
      increment_occurences_in_day_report
    end

    def increment_occurences_in_month_report
      @month_report.increment(:occurences)
      @month_report.save
    end

    def increment_occurences_in_day_report
      @day_report.increment(:occurences)
      @day_report.save
    end
  end
end
