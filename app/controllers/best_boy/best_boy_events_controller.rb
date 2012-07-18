module BestBoy
  class BestBoyEventsController < BestBoy.base_controller.constantize

    before_filter BestBoy.before_filter if BestBoy.before_filter.present?
    before_filter :prepare_chart, :only => [:charts]
    skip_before_filter BestBoy.skip_before_filter if BestBoy.skip_before_filter.present?

    layout 'best_boy_backend'

    helper_method :available_owner_types, :available_events, :available_event_sources, :available_years, :current_owner_type, 
                  :current_event, :current_event_source, :current_year, :collection, :statistics, :stats_by_event_and_month, 
                  :stats_by_event_source_and_month, :render_chart, :event_source_details, :month_name_array, :detail_count

    private

    def render_chart(chart, dom)
      chart.to_js(dom).html_safe
    end

    def week_name_array
      %w(Mon Tue Wed Thu Fri Sat Sun)
    end

    def month_name_array
      %w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)
    end

    def custom_data_count(time)
      scope = BestBoyEvent.where("best_boy_events.owner_type = ?", current_owner_type)
      scope = scope.where("best_boy_events.event = ?", current_event) if current_event.present?
      scope = scope.where("best_boy_events.event_source = ?", current_event_source) if current_event_source.present?
      scope = scope.send("per_#{ current_time_interval == "year" ? "month" : "day" }", time)
      scope.count
    end

    def time_periode_range
      case current_time_interval
      when "month"
        (0..(Time.days_in_month(Time.zone.now.month) - 1))
      when "week"
        (0..6)
      else
        (0..11)
      end
    end

    def calculated_point_in_time(periode)
      case current_time_interval
      when "month"
        Time.zone.now.beginning_of_month + periode.days
      when "week"
        Time.zone.now.beginning_of_week + periode.days
      else
        Time.zone.now.beginning_of_year + periode.month
      end
    end

    def chart_legend_time_name(periode)
      case current_time_interval
      when "year"
        month_name_array[periode]
      when "week"
        week_name_array[periode]
      else
        (periode + 1).to_s
      end
    end

    def stats_by_event_and_month(event, month)
      date = "1-#{month}-#{current_year}".to_time
      BestBoyEvent.where("best_boy_events.owner_type = ? AND best_boy_events.event = ?", current_owner_type, event).per_month(date).count
    end

    def stats_by_event_source_and_month(source, month)
      date = "1-#{month}-#{current_year}".to_time
      if source.present?
        scope = BestBoyEvent.where("best_boy_events.owner_type = ? AND best_boy_events.event = ? AND best_boy_events.event_source = ?", current_owner_type, current_event, source)
      else
        scope = BestBoyEvent.where("best_boy_events.owner_type = ? AND best_boy_events.event = ? AND best_boy_events.event_source IS NULL", current_owner_type, current_event)
      end
      scope.per_month(date).count
    end

    def current_date
      @current_date ||= Date.strptime(params[:date], "%d-%m-%Y") if params[:date] rescue nil
    end

    def current_event
      @current_event ||= available_events.include?(params[:event]) ? params[:event] : nil
    end

    def current_event_source
      @current_event_source ||= available_event_sources.include?(params[:event_source]) ? params[:event_source] : nil
    end

    def current_owner_type
      @current_owner_type ||= available_owner_types.include?(params[:owner_type]) ? params[:owner_type] : available_owner_types.first
    end

    def current_time_interval
      @current_time_interval ||= %w(year month week).include?(params[:time_interval]) ? params[:time_interval] : "year"
    end

    def current_year
      @current_year ||= available_years.include?(params[:year]) ? params[:year] : Time.zone.now.year
    end

    def available_events
      @available_events ||= (
        scope = BestBoyEvent.where("best_boy_events.owner_type = ?", current_owner_type)
        scope = scope.select("best_boy_events.event").order("best_boy_events.event ASC")
        scope = scope.group("best_boy_events.event").map(&:event)
      )
    end

    def available_event_sources
      @available_event_sources ||= (
        scope = BestBoyEvent.where("best_boy_events.owner_type = ? AND best_boy_events.event = ?", current_owner_type, current_event)
        scope = scope.select("best_boy_events.event_source").order("best_boy_events.event_source ASC")
        scope = scope.group("best_boy_events.event_source").map(&:event_source)
      )
    end

    def available_years
      @available_years = (BestBoyEvent.where("best_boy_events.owner_type = ?", current_owner_type).order("best_boy_events.created_at ASC").first.created_at.to_date.year..Time.zone.now.year).map{ |year| year.to_s } rescue [Time.zone.now.year]
    end

    def available_owner_types
      @available_owner_types ||= BestBoyEvent.select("DISTINCT best_boy_events.owner_type").order("best_boy_events.owner_type ASC").map(&:owner_type)
    end

    def detail_count
      @detail_count ||= current_scope({:owner_type => params[:owner_type], :event => params[:event]}).count
    end

    def current_scope(options = {})
      options.each do |key, value| 
        instance_var = "@#{key}" 
        instance_variable_set(instance_var, value)
      end

      scope = BestBoyEvent
      scope = scope.where("best_boy_events.owner_type = ?", @owner_type) if @owner_type.present?
      scope = scope.where("best_boy_events.event = ?", @event) if @event.present?
      scope = scope.where("best_boy_events.event_source = ?", @event_source) if @event_source.present?
      scope = scope.per_day(@date) if @date.present?
      scope
    end

    def prepare_details(base_collection, key, options = {})
      array = Array.new
      base_collection.each do |item|
        scope = current_scope(options.to_a + [[key.to_sym, item]])
        array.push([item, scope.count] + %w(year month week day).map{ |delimiter| scope.send("per_#{delimiter}", Time.zone.now).count })
      end
      array
    end

    def collection
      @best_boy_events ||= (
        scope = current_scope({:owner_type => params[:owner_type], :event_source => current_event, :date =>  current_date})
        scope = scope.order("best_boy_events.created_at DESC, best_boy_events.event ASC")
        scope.page(params[:page]).per(50)
      )
    end

    def statistics
      @statistics = prepare_details(available_events, "event", {:owner_type => current_owner_type})
    end

    def event_source_details
      @event_source_details = prepare_details(available_event_sources, "event_source", {:owner_type => current_owner_type, :event => current_event})
    end

    def prepare_chart
      data_table = GoogleVisualr::DataTable.new
      data_table.new_column('string', 'time')
      data_table.new_column('number', current_owner_type.to_s)
      time_periode_range.each do |periode|
        data_table.add_row([chart_legend_time_name(periode), custom_data_count(calculated_point_in_time(periode))])
      end
      @chart = GoogleVisualr::Interactive::AreaChart.new(data_table, { width: 900, height: 240, title: "" })
    end
  end
end