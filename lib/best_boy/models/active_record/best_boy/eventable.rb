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
      reports_for "create"
    end

    def trigger_destroy_event
      return if self.class.best_boy_disable_callbacks
      create_best_boy_event_with_type "destroy"
      reports_for "destroy"
    end

    def trigger_best_boy_event type, source = nil
      create_best_boy_event_with_type(type, source)
    end

    def create_best_boy_event_with_type type, source = nil
      raise "nil event is not allowed" if type.blank?
      best_boy_event = BestBoyEvent.new(:event => type, :event_source => source)
      best_boy_event.owner = self
      best_boy_event.save
    end

    def reports_for type
    end
  end
end
