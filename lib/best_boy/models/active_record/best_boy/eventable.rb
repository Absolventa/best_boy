module BestBoy
  module Eventable
    extend ActiveSupport::Concern

    module ClassMethods
      def has_a_best_boy
        # meta programming
        #
        #
        include InstanceMethods
        
        # associations
        #
        #
        has_many :best_boy_events, :as => :owner, :dependent => :nullify
        
        # callbacks
        #
        #
        after_create :trigger_create_event
        before_destroy :trigger_destroy_event
      end
    end

    module InstanceMethods
      def trigger_create_event
        create_best_boy_event_with_type "create"
      end

      def trigger_destroy_event
        create_best_boy_event_with_type "destroy"
      end

      def trigger_custom_event type
        create_best_boy_event_with_type(type) if type.present? 
      end

      def create_best_boy_event_with_type type
        best_boy_event = BestBoyEvent.new(:event => type)
        best_boy_event.owner = self
        best_boy_event.save
      end
    end
  end
end
