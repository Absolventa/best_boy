module BestBoy
  module InstanceMethods
    def trigger_create_event
      create_best_boy_event_with_type "create"
    end

    def trigger_destroy_event
      create_best_boy_event_with_type "destroy"
    end

    def create_best_boy_event_with_type type
      best_boy_event = BestBoy::BestBoyEvent.new(:event => type)
      best_boy_event.owner = self
      best_boy_event.save
    end
  end
end