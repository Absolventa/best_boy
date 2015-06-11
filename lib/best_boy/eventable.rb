module BestBoy
  module Eventable
    extend ActiveSupport::Concern

    module ClassMethods
      attr_accessor :best_boy_disable_callbacks

      def has_a_best_boy(options={})
        # constants
        #
        #
        self.best_boy_disable_callbacks = options[:disable_callbacks]

        # associations
        #
        #
        has_many :best_boy_events, as: :owner, class_name: "BestBoy::Event", dependent: :nullify


        # callbacks
        #
        #
        after_create :trigger_create_event
        after_destroy :trigger_destroy_event
      end
    end

    def trigger_best_boy_event type, source = nil
      create_best_boy_event_with_type(type, source)
    end

    def trigger_best_boy_event_report(klass: self.class.to_s, type: '', source: nil, date: Time.zone.now)
      BestBoy::MonthReport.current_or_create_for(klass, type, source, date).increment!(:occurrences)
      BestBoy::DayReport.current_or_create_for(klass, type, source, date).increment!(:occurrences)
    end

    private

    def trigger_create_event
      return if self.class.best_boy_disable_callbacks
      create_best_boy_event_with_type "create"
    end

    def trigger_destroy_event
      return if self.class.best_boy_disable_callbacks
      create_best_boy_event_with_type "destroy"
    end

    def create_best_boy_event_with_type(type, source = nil)
      raise "nil event is not allowed" if type.blank?
      best_boy_event = BestBoy::Event.new do |bbe|
        bbe.event        = type
        bbe.event_source = source
        bbe.owner        = self
      end
      best_boy_event.save

      trigger_best_boy_event_report(type: type, source: source) if source.present?
      trigger_best_boy_event_report(type: type, source: nil)
    end

  end
end
