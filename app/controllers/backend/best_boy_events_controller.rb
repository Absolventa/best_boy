module BestBoyBackend
  class BestBoyEventsController < ::ApplicationController

    layout :best_boy_backend

    def index
      collection
    end

    private

    def collection
      @best_boy_events ||= BestBoyEvent.order("best_boy_events.owner_type, best_boy_events.event ASC")
    end

  end
end