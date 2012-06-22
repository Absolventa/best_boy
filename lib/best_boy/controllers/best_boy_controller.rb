module BestBoyController
  module InstanceMethods
    def best_boy_event(obj, event)
      if obj.respond_to?("eventable?")
        obj.trigger_custom_event(event)
      else
        raise "#{obj.class.to_s} is not a best_boy eventable!"
      end
    end
  end
end