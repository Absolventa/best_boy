# frozen_string_literal: true
module BestBoy
  class EventsController < BestBoy.base_controller.constantize

    before_action BestBoy.before_filter if BestBoy.before_filter.present?

    skip_before_action BestBoy.skip_before_filter if BestBoy.skip_before_filter.present?
    skip_after_action BestBoy.skip_after_filter if BestBoy.skip_after_filter.present?

    layout 'best_boy/best_boy'


    helper BestBoy::BestBoyViewHelper
    helper_method :available_owner_types, :available_events, :available_event_sources, :available_event_sources?, :available_years,
                  :current_owner_type, :current_event, :current_event_source, :current_month, :current_year, :collection,
                  :days_of, :month_name_array, :detail_count

    def stats
      collect_occurrences
      collect_occurrences_for_selected_year
      available_events_totals
      selected_year_totals
    end

    def details
      collect_occurrences
      collect_occurrences_grouped_by_sources
      collect_occurrences_for_selected_year_of current_event
      selected_year_totals
    end

    def monthly_details
      collect_occurrences_for_month current_month
      monthly_details_chart
    end

    private

    def collect_event_occurrences(event)
      {
        event => {
          :daily   => BestBoy::DayReport.daily_occurrences_for(current_owner_type, event, nil, Time.zone.now),
          :weekly  => BestBoy::DayReport.weekly_occurrences_for(current_owner_type, event),
          :monthly => BestBoy::MonthReport.monthly_occurrences_for(current_owner_type, event, nil, Time.zone.now),
          :yearly  => BestBoy::MonthReport.yearly_occurrences_for(current_owner_type, event, nil, Time.zone.now),
          :overall => BestBoy::MonthReport.overall_occurrences_for(current_owner_type, event)
        }
      }
    end

    def collect_occurrences
      @occurrences = {}
      available_events.each { |event| @occurrences.merge! collect_event_occurrences(event) }
    end

    def collect_source_occurrences(source)
      {
        source => {
          :daily   => BestBoy::DayReport.daily_occurrences_for(current_owner_type, current_event, source, Time.zone.now),
          :weekly  => BestBoy::DayReport.weekly_occurrences_for(current_owner_type, current_event, source),
          :monthly => BestBoy::MonthReport.monthly_occurrences_for(current_owner_type, current_event, source, Time.zone.now),
          :yearly  => BestBoy::MonthReport.yearly_occurrences_for(current_owner_type, current_event, source, Time.zone.now),
          :overall => BestBoy::MonthReport.overall_occurrences_for(current_owner_type, current_event, source)
        }
      }
    end

    def collect_occurrences_grouped_by_sources
      @sourced_occurrences = {}
      available_event_sources.each { |source| @sourced_occurrences.merge! collect_source_occurrences(source) }
    end

    def collect_occurrences_for_month(month)
      @selected_month_occurrences = {}
      sources = available_event_sources.to_a + ["All"]
      sources.each do |source|
        @selected_month_occurrences.merge!({source => {}})
        days_of(month).each do |day|
          query_source = source == "All" ? nil : source
          branch       = {day =>  BestBoy::DayReport.daily_occurrences_for(current_owner_type, current_event, query_source, day)}
          @selected_month_occurrences[source].merge!(branch)
        end
      end
    end

    def collect_occurrences_for_selected_year
      @selected_year_occurrences = {}
      available_events.each do |event|
        @selected_year_occurrences.merge!({event => {}})
        (1..12).each do |month|
          date = Date.parse("#{current_year}-#{month}-1")
          @selected_year_occurrences[event].merge!({month.to_s => BestBoy::MonthReport.monthly_occurrences_for(current_owner_type, event, nil, date)})
        end
      end
    end

    def collect_occurrences_for_selected_year_of(event)
      @event_selected_year_occurrences = {}
      sources = available_event_sources.to_a + ["All"]

      sources.each do |source|
        @event_selected_year_occurrences.merge!({source => {}})
        (1..12).each do |month|
          date         = Date.parse("#{current_year}-#{month}-1")
          query_source = source == "All" ? nil : source
          branch       = {month.to_s => BestBoy::MonthReport.monthly_occurrences_for(current_owner_type, event, query_source, date)}
          @event_selected_year_occurrences[source].merge!(branch)
        end
      end
    end

    def available_events_totals
      @this_year_totals     = { :daily => 0, :weekly => 0, :monthly => 0, :yearly => 0, :overall => 0 }
      available_events.each do |event|
        @this_year_totals.keys.each do |time_period|
          @this_year_totals[time_period] += @occurrences[event][time_period]
        end
      end
    end

    def selected_year_totals
      @selected_year_totals = {}
      # OPTIMIZE ME:
      # Query below could be replaced with a GROUP_BY or similar
      # SQL-statement for performance boost, i.e. similar to
      # BestBoy::MonthReport.select("SUM(occurances) AS counter, DATE_PART('month', created_at) as month").where(:owner_type => current_owner_type, created_at: current_year.beginning_of_year..current_year.end_of_year).group("DATE_PART('month', created_at)")
      (1..12).each do |month|
        date   = Date.parse("#{current_year}-#{month}-1")
        branch = { month => BestBoy::MonthReport.where(owner_type: current_owner_type, event_source: nil)
                                                .between(date.beginning_of_month, date.end_of_month)
                                                .sum(:occurrences) }
        @selected_year_totals.merge!(branch)
      end
    end

    def days_of(month)
      reference = Date.parse("#{current_year}-#{month}-01")
      (reference.beginning_of_month..reference.end_of_month)
    end

    def chart_for(data)
      @chart = GoogleVisualr::Interactive::AreaChart.new(data, { width: 1100, height: 300, title: "" })
    end

    def row_values_for(day)
      available_event_sources.collect{ |event_source| @selected_month_occurrences[event_source][day] } + [@selected_month_occurrences["All"][day]]
    end

    def monthly_details_chart
      data_table = GoogleVisualr::DataTable.new
      data_table.new_column('string', 'time')

      labels = available_event_sources.to_a + ["All"]
      labels.each { |label| data_table.new_column('number', label.to_s) }

      days_of(params[:month]).each { |day| data_table.add_row( [day.strftime("%d")] + row_values_for(day) ) }
      chart_for data_table
    end

    def build_chart
      data_table = GoogleVisualr::DataTable.new
      data_table.new_column('string', 'time')
      data_table.new_column('number', current_owner_type.to_s)

      time_periode_range.each do |periode|
        data_table.add_row([chart_legend_time_name(periode), custom_data_count(current_event_source, calculated_point_in_time(periode))])
      end
      chart_for data_table
    end

    def week_name_array
      %w(Mon Tue Wed Thu Fri Sat Sun)
    end

    def month_name_array
      %w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)
    end

    def custom_data_count(source, time)
      scope = %("week", "month").include?(current_time_interval) ? BestBoy::DayReport.created_on(time) : BestBoy::MonthReport.between(time.beginning_of_month, time.end_of_month)
      scope = scope.where(owner_type: current_owner_type)
      scope = scope.where(event: current_event) if current_event.present?
      scope = scope.where(event_source: source) if source.present?
      scope = scope.where(event_source: nil) if source.nil?
      scope.sum(:occurrences)
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

    def current_month
      @current_month ||= month_name_array.include?(params[:month]) ? params[:month] : Time.zone.now.month
    end

    def available_events
      @available_events ||= BestBoy::MonthReport.where(owner_type: current_owner_type).order(:event).uniq.pluck(:event)
    end

    def available_event_sources
      @available_event_sources ||= (
        BestBoy::MonthReport.where(owner_type: current_owner_type).where('event_source IS NOT NULL').order(:event_source).uniq.pluck(:event_source)
      )
    end

    def available_event_sources?
      available_event_sources.first.present?
    end

    def available_years
      @available_years = (BestBoy::MonthReport.where(owner_type: current_owner_type, event_source: nil).order(:created_at).first.created_at.to_date.year..Time.zone.now.year).map{ |year| year.to_s } rescue [Time.zone.now.year]
    end

    def available_owner_types
      @available_owner_types ||= BestBoy::MonthReport.where(event_source: nil).order(:owner_type).uniq.pluck(:owner_type)
    end

    def detail_count
      @detail_count ||= current_scope({:owner_type => params[:owner_type], :event => params[:event]}).count
    end

    def current_scope(options = {})
      options.each do |key, value|
        instance_var = "@#{key}"
        instance_variable_set(instance_var, value)
      end

      scope = BestBoy::Event
      scope = scope.where(owner_type: @owner_type) if @owner_type.present?
      scope = scope.where(event: @event) if @event.present?
      scope = scope.where(event_source: @event_source) if @event_source.present?
      scope = scope.per_day(@date) if @date.present?
      scope
    end

    def collection
      @best_boy_events ||= (
        scope = current_scope({owner_type: params[:owner_type],event: current_event, event_source: current_event_source, date: current_date})
        scope.order("created_at DESC, event ASC").page(params[:page]).per(50)
      )
    end

  end
end
