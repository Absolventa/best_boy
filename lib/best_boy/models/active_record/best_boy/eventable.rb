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
        has_many :best_boy_events, as: :owner, dependent: :nullify

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
      best_boy_event = BestBoyEvent.new do |bbe|
        bbe.event        = type
        bbe.event_source = source
        bbe.owner        = self
      end
      best_boy_event.save
      report type, source
    end

    def report type, source = nil
      month_report             = BestBoy::MonthReport.current_or_create_for(self.class.to_s, type)
      month_report_with_source = BestBoy::MonthReport.current_or_create_for(self.class.to_s, type, source) if source.present?

      day_report             = BestBoy::DayReport.current_or_create_for(self.class.to_s, type)
      day_report_with_source = BestBoy::DayReport.current_or_create_for(self.class.to_s, type, source) if source.present?

      increment_occurrences_in_reports month_report, month_report_with_source, day_report, day_report_with_source
    end

    def increment_occurrences_in_reports(month_report, month_report_with_source, day_report, day_report_with_source)
      day_report_with_source.increment!(:occurrences) if day_report_with_source.present?
      month_report_with_source.increment!(:occurrences) if month_report_with_source.present?

      day_report.increment!(:occurrences)
      month_report.increment!(:occurrences)
    end
  end
end
