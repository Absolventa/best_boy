module BestBoyController
  module InstanceMethods
    def best_boy_event(obj, event, source = nil)
      if obj.respond_to?("eventable?")
        obj.trigger_best_boy_event(event, source)
      else
        raise "#{obj.class.to_s} is not a best_boy eventable!"
      end
    end
  end
end