module BestBoy
  class BestBoyEventsController < BestBoy.base_controller.constantize

    before_action BestBoy.before_filter if BestBoy.before_filter.present?
    before_action :prepare_chart, :only => [:charts]

    skip_before_filter BestBoy.skip_before_filter if BestBoy.skip_before_filter.present?
    skip_after_filter BestBoy.skip_after_filter if BestBoy.skip_after_filter.present?

    layout 'best_boy_backend'

    helper_method :available_owner_types, :available_events, :available_event_sources, :available_years,
                  :current_owner_type, :current_event, :current_event_source, :current_month, :current_year, :collection,
                  :render_chart, :month_name_array, :detail_count


    def weekly_occurences_for event
      BestBoy::DayReport.week.where(eventable_type: current_owner_type, event_type: event, event_source: nil).sum(:occurences)
    end

    def monthly_occurences_for event, month, year
      BestBoy::MonthReport.where(eventable_type: current_owner_type, event_type: event, event_source: nil).month(month, year).sum(:occurences)
    end

    def yearly_occurences_for event, year
      BestBoy::MonthReport.where(eventable_type: current_owner_type, event_type: event, event_source: nil).between(Time.now.beginning_of_year, Time.now).sum(:occurences)
    end

    def overall_occurences_for event
      BestBoy::MonthReport.where(eventable_type: current_owner_type, event_type: event, event_source: nil).sum(:occurences)
    end

    def grab_reports_for_this_year
      @day_reports, @month_reports, @occurences = {}, {}, {}

      available_events.each do |event|
        @day_reports[event]   = BestBoy::DayReport.current_for(Time.now, current_owner_type, event, nil).last
        @month_reports[event] = BestBoy::MonthReport.current_for(Time.now, current_owner_type, event, nil).last
        @occurences           = @occurences.merge({ event => {
          :daily => @day_reports[event].present? ? @day_reports[event].occurences : 0,
          :weekly => weekly_occurences_for(event),
          :monthly => @month_reports[event].present? ? @month_reports[event].occurences : 0,
          :yearly => yearly_occurences_for(event, current_year),
          :overall => overall_occurences_for(event)
        }})
      end
    end

    def crunch_data_for_selected_year
      @selected_year_month_reports = {}
      available_events.each { |event| crunch_data_for_selected_year_of event }
    end

    def crunch_data_for_selected_year_of event
      @selected_year_month_reports = @selected_year_month_reports.merge({event => {}})

      (1..12).each do |month|
        @selected_year_month_reports[event] = @selected_year_month_reports[event].merge({
          month => BestBoy::MonthReport.where(eventable_type: current_owner_type, event_type: event).month(month, current_year).sum(:occurences)
        })
      end
    end

    def compute_totals
      @this_year_totals = { :daily => 0, :weekly => 0, :monthly => 0, :yearly => 0, :overall => 0 }
      @selected_year_totals = {}

      available_events.each do |event|
        @this_year_totals[:daily]   += @occurences[event][:daily]
        @this_year_totals[:weekly]  += @occurences[event][:weekly]
        @this_year_totals[:monthly] += @occurences[event][:monthly]
        @this_year_totals[:yearly]  += @occurences[event][:yearly]
        @this_year_totals[:overall] += @occurences[event][:overall]

        (1..12).each do |month|
          @selected_year_totals = @selected_year_totals.update(
            { month => monthly_occurences_for(event, month, current_year) }
          ) { |key, value1, value2| value1+value2  } # sum up values each time hash is updated
        end
      end
    end

    def stats
      grab_reports_for_this_year
      crunch_data_for_selected_year
      compute_totals
    end

    def details
      counter_scope = BestBoyEvent.select("COUNT(*) as counter, event_source").where(owner_type: current_owner_type, event: current_event).group('event_source')

      # Custom hash for current event_source stats - current_year, current_month, current_week, current_day (with given current_owner_type)
      # We fire 5 database queries, one for each group, to keep it database acnostic.
      # Before we had 5 * n event_sources queries
      @event_source_counts_per_group = {}
      overall_hash = counter_scope.inject({}){ |hash, element| hash[element.event_source] = element.counter; hash}
      current_year_hash = counter_scope.per_year(Time.zone.now).inject({}){ |hash, element| hash[element.event_source] = element.counter; hash}
      current_month_hash = counter_scope.per_month(Time.zone.now).inject({}){ |hash, element| hash[element.event_source] = element.counter; hash}
      current_week_hash = counter_scope.per_week(Time.zone.now).inject({}){ |hash, element| hash[element.event_source] = element.counter; hash}
      current_day_hash = counter_scope.per_day(Time.zone.now).inject({}){ |hash, element| hash[element.event_source] = element.counter; hash}

      available_event_sources.each do |event_source|
        @event_source_counts_per_group[event_source] ||= {}
        @event_source_counts_per_group[event_source]['overall'] = overall_hash[event_source] || 0
        @event_source_counts_per_group[event_source]['year'] = current_year_hash[event_source] || 0
        @event_source_counts_per_group[event_source]['month'] = current_month_hash[event_source] || 0
        @event_source_counts_per_group[event_source]['week'] = current_week_hash[event_source] || 0
        @event_source_counts_per_group[event_source]['day'] = current_day_hash[event_source] || 0
      end

      # Custom hash for current event_sources stats per month (with given current_owner_type and given event)
      # We fire 12 database queries, one for each month, to keep it database acnostic.
      # Before we had 12 * n event_sources queries
      @event_sources_counts_per_month = {}
      %w(1 2 3 4 5 6 7 8 9 10 11 12).each do |month|
        month_hash = counter_scope.per_month("1-#{month}-#{current_year}".to_time).inject({}){ |hash, element| hash[element.event_source] = element.counter; hash}

        available_event_sources.each do |event_source|
          @event_sources_counts_per_month[event_source] ||= {}
          @event_sources_counts_per_month[event_source][month] = month_hash[event_source] || 0
        end
      end
    end


    def monthly_details
      counter_scope = BestBoyEvent.select("COUNT(*) as counter, event_source").where(owner_type: current_owner_type, event: current_event).group('event_source')
      days = 1..(Time.days_in_month("1-#{current_month}-#{current_year}".to_time.month))
      # Custom hash for current event_sources stats per month (with given current_owner_type and given event)
      # We fire a max of 31 database queries, one for each day, to keep it database acnostic.
      # Before we had 31 * n event_sources queries
      @event_sources_counts_per_day = {}
      days.each do |day|
        day_hash = counter_scope.per_day("#{day}-#{current_month}-#{current_year}".to_time).inject({}){ |hash, element| hash[element.event_source] = element.counter; hash}

        available_event_sources.each do |event_source|
          @event_sources_counts_per_day[event_source] ||= {}
          @event_sources_counts_per_day[event_source][day] = day_hash[event_source] || 0
        end
      end

      data_table = GoogleVisualr::DataTable.new
      data_table.new_column('string', 'time')
      available_event_sources.each do |source|
        data_table.new_column('number', source.to_s)
      end

      days.each do |day|
        time = "#{day}-#{current_month}-#{current_year}".to_time
        data_table.add_row( [ day.to_s] + available_event_sources.map{ |event_source| @event_sources_counts_per_day[event_source][day].to_i })
      end
      @chart = GoogleVisualr::Interactive::AreaChart.new(data_table, { width: 900, height: 240, title: "" })
    end


    private

    def render_chart(chart, dom)
      chart.to_js(dom).html_safe
    end

    def prepare_chart
      data_table = GoogleVisualr::DataTable.new
      data_table.new_column('string', 'time')
      data_table.new_column('number', current_owner_type.to_s)
      time_periode_range.each do |periode|
        data_table.add_row([chart_legend_time_name(periode), custom_data_count(current_event_source, calculated_point_in_time(periode))])
      end
      @chart = GoogleVisualr::Interactive::AreaChart.new(data_table, { width: 900, height: 240, title: "" })
    end

    def week_name_array
      %w(Mon Tue Wed Thu Fri Sat Sun)
    end

    def month_name_array
      %w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)
    end

    def custom_data_count(source, time)
      scope = %("week", "month").include?(current_time_interval) ? BestBoy::DayReport.created_on(time) : BestBoy::MonthReport.month(time.month, time.year)
      scope = scope.where(eventable_type: current_owner_type)
      scope = scope.where(event_type: current_event) if current_event.present?
      scope = scope.where(event_source: source) if source.present?
      scope = scope.where(event_source: nil) if source.nil?
      scope.sum(:occurences)
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
      @available_events ||= BestBoyEvent.select('DISTINCT event').where(owner_type: current_owner_type).order(:event).map(&:event)
    end

    def available_event_sources
      @available_event_sources ||= (
        BestBoyEvent.select("DISTINCT event_source").where(owner_type: current_owner_type, event: current_event).order(:event_source).map(&:event_source)
      )
    end

    def available_years
      @available_years = (BestBoyEvent.where(owner_type: current_owner_type).order(:created_at).first.created_at.to_date.year..Time.zone.now.year).map{ |year| year.to_s } rescue [Time.zone.now.year]
    end

    def available_owner_types
      @available_owner_types ||= BestBoyEvent.select("DISTINCT owner_type").order(:owner_type).map(&:owner_type)
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
