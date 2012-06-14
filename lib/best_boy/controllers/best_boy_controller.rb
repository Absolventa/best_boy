module BestBoyController
  module InstanceMethods
    def best_boy_event(obj, event)
      if obj.respond_to?("eventable?")
        if event.present?
          obj.trigger_custom_event(event)
        else
          raise "There is no event to trigger."
        end
      else
        raise "#{obj.class.to_s} is not a best_boy eventable!"
      end
    end
  end
end