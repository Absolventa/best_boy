module BestBoyBackend
  class Backend::BestBoyEventsController < ::ApplicationController

    layout 'best_boy_backend'

    helper_method :available_owner_types, :available_events, :current_owner_type, :collection, :statistics, :stats_by_event_and_month

    def stats
      collection
    end

    private

    def current_owner_type
      @current_owner_type ||= available_owner_types.include?(params[:owner_type]) ? params[:owner_type] : available_owner_types.first
    end

    # def current_event
    #   @current_event ||= available_events.include?(params[:event]) ? params[:event] : nil
    # end

    def available_owner_types
      @available_owner_types ||= BestBoyEvent.select("DISTINCT owner_type").map(&:owner_type)
    end

    def available_events
      @available_events ||= BestBoyEvent.where("owner_type = ?", current_owner_type).select("event").order("event ASC").group("event").map(&:event)
    end

    def collection
      @best_boy_events ||= (
        scope = BestBoyEvent.where("owner_type = ?", current_owner_type)
        scope = scope.order("event ASC")
      )
    end

    def statistics
      @statistics = Array.new
      now = Time.zone.now
      available_events.each do |event|
        scope = BestBoyEvent.where("owner_type = ? AND event = ?", current_owner_type, event)
        @statistics.push([event, scope.count] + %w(year month week day).map{ |delimiter| scope.send("per_#{delimiter}", Time.zone.now).count })
      end
      logger.info @statistics.inspect
      return @statistics
    end

    def stats_by_event_and_month event, month
      date = "1-#{month}-#{Time.zone.now.year}".to_time
      BestBoyEvent.where("owner_type = ? AND event = ?", current_owner_type, event).per_month(date).count
    end
  end
end