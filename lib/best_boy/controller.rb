module BestBoy
  module Controller
    extend ActiveSupport::Concern

    protected

    def best_boy_event(obj, event, source = nil)
      obj.trigger_best_boy_event(event, source)
    end

  end
end