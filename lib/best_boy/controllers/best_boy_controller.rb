module BestBoyController
  module InstanceMethods
    protected

    def best_boy_event(obj, event, source = nil)
      obj.trigger_best_boy_event(event, source)
    end
  end
end
