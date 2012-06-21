module BestBoy
  class BestBoyEventsController < BestBoy.base_controller.constantize

    before_filter BestBoy.before_filter if BestBoy.before_filter.present?
    skip_before_filter BestBoy.skip_before_filter if BestBoy.skip_before_filter.present?

    layout 'best_boy_backend'

    helper_method :available_owner_types, :available_events, :available_years, :current_owner_type, :current_event, :current_year, :collection, :statistics, :stats_by_event_and_month, :render_chart

    def charts
      build_chart available_owner_types
      
      (0..11).each do |month|
        row = [(month + 1).to_s]
        available_owner_types.each do |owner_type|
          row.push(data_count_for_event_and_owner_type "create", owner_type, "month", Time.zone.now.beginning_of_year + month.month)
        end
        data_table.add_row(row)
      end

      draw_chart { width: 900, height: 240, title: '"Create" Events over model' }

      option = { width: 900, height: 240, title: '"Create" Events over model' }
      @chart = GoogleVisualr::Interactive::AreaChart.new(data_table, option)
    end

    private

    def build_chart chart_rows
      data_table = GoogleVisualr::DataTable.new
      data_table.new_column('string', 'time')
      chart_rows.each do |row|
        data_table.new_column('number', row.to_s)
      end
    end

    def draw_chart data_table, options
      @chart = GoogleVisualr::Interactive::AreaChart.new(data_table, options)
    end

    def data_count_for_event_and_owner_type event, owner_type, scope, time
      BestBoyEvent.where("best_boy_events.event = ? AND best_boy_events.owner_type = ?", event, owner_type).send("per_#{scope}", time).count
    end

    def render_chart(chart, dom)
        chart.to_js(dom).html_safe
      end

    def current_owner_type
      @current_owner_type ||= available_owner_types.include?(params[:owner_type]) ? params[:owner_type] : available_owner_types.first
    end

    def current_event
      @current_event ||= available_events.include?(params[:event]) ? params[:event] : nil
    end

    def current_date
      @current_date ||= Date.strptime(params[:date], "%d-%m-%Y") if params[:date] rescue nil
    end

    def current_year
      @current_year ||= available_years.include?(params[:year]) ? params[:year] : Time.zone.now.year
    end

    def available_owner_types
      @available_owner_types ||= BestBoyEvent.select("DISTINCT best_boy_events.owner_type").order("best_boy_events.owner_type ASC").map(&:owner_type)
    end

    def available_events
      @available_events ||= BestBoyEvent.where("best_boy_events.owner_type = ?", current_owner_type).select("best_boy_events.event").order("best_boy_events.event ASC").group("best_boy_events.event").map(&:event)
    end

    def available_years
      @available_years = (BestBoyEvent.order("best_boy_events.created_at ASC").first.created_at.to_date.year..Time.zone.now.year).map{ |year| year.to_s } rescue [Time.zone.now.year]
    end

    def collection
      @best_boy_events ||= (
        scope = BestBoyEvent.where("best_boy_events.owner_type = ?", current_owner_type)
        scope = scope.where("best_boy_events.event = ?", current_event) if current_event.present?
        scope = scope.per_day(current_date) if current_date.present?
        scope = scope.order("best_boy_events.created_at DESC, best_boy_events.event ASC")
        scope.page(params[:page]).per(50)
      )
    end

    def statistics
      @statistics = Array.new
      available_events.each do |event|
        scope = BestBoyEvent.where("best_boy_events.owner_type = ? AND best_boy_events.event = ?", current_owner_type, event)
        @statistics.push([event, scope.count] + %w(year month week day).map{ |delimiter| scope.send("per_#{delimiter}", Time.zone.now).count })
      end
      @statistics
    end

    def stats_by_event_and_month event, month
      date = "1-#{month}-#{current_year}".to_time
      BestBoyEvent.where("best_boy_events.owner_type = ? AND best_boy_events.event = ?", current_owner_type, event).per_month(date).count
    end

  end
end