namespace :best_boy do
  desc "Creates consistent structure of DayReports and MonthReports for a given set of events"
  task :recover_report_history, [:date]  => :environment do |t, args| 

    # helper methods
    #
    #

    def month_report_id_for(year, owner_type, source, event) 
      date = Date.parse("#{year}-01-01")
      BestBoy::MonthReport.where(created_at:   date.beginning_of_day..date.end_of_year.end_of_day, 
                                 owner_type:   owner_type, 
                                 event_source: source, 
                                 event:        event).first.id
    end

    def flush
      print "."
      STDOUT.flush
    end

    # Read optional date
    #
    #

    start = args.date.present? ? Date.parse(args.date) : nil
    
    puts ""
    puts "> Destroying all reports ..."
    puts ">... that where created after beginning of day #{start}" if start.present?
    puts ""

    # Destroy all existing reports
    #
    #

    if start.present?
      BestBoy::MonthReport.between(start, Date.today).destroy_all
      BestBoy::DayReport.where(created_at: start.beginning_of_day..Date.today.end_of_day).destroy_all
    else
      BestBoy::MonthReport.destroy_all
      BestBoy::DayReport.destroy_all
    end

    puts ""
    puts "> Selected report data has been destroyed."
    puts ""

    owner_types             = BestBoyEvent.order(:owner_type).uniq.pluck(:owner_type)
    available_events        = {}
    available_event_sources = {}

    owner_types.each do |owner_type|
      available_events.merge!(        { owner_type => BestBoyEvent.where(owner_type: owner_type).order(:event).uniq.pluck(:event) } )
      available_event_sources.merge!( { owner_type => BestBoyEvent.where(owner_type: owner_type).order(:event_source).uniq.pluck(:event_source) } ) # explicitly including nil
    end

    start = BestBoyEvent.order('created_at ASC').first.created_at.to_date unless start.present?
    days  = (start..BestBoyEvent.order('created_at ASC').last.created_at.to_date)
    
    puts ""
    puts "> Start creating new reports for #{days.count} days ..."
    puts ""

    days.each do |day|
      owner_types.each do |owner_type|
        available_events[owner_type].each do |event|
          available_event_sources[owner_type].each do |source|

            # Create MonthReports when...
            # - diving into loop initially or
            # - a new month starts

            if day.day == 1 || days.first == day

              # Check if Events occured during the whole month.
              # If any, create MonthReports.

              month_scope = BestBoyEvent.where(created_at: day.beginning_of_month.beginning_of_day..day.end_of_month.end_of_day)
                                        .where(owner_type: owner_type, event: event, event_source: source)
                                        .order('created_at DESC')

              monthly_occurrences = month_scope.count

              if monthly_occurrences > 0                
                artifical_created_at = month_scope.first.created_at
                if source.present?
                  month_report_with_source = BestBoy::MonthReport.create(
                    owner_type:     owner_type, 
                    event:          event,
                    event_source:   source,
                    occurrences:    monthly_occurrences 
                  ).tap { |r| r.created_at = artifical_created_at; r.save }
                end

                month_report_without_source = BestBoy::MonthReport.create(
                  owner_type:     owner_type, 
                  event:          event,
                  event_source:   nil,
                  occurrences:    monthly_occurrences 
                ).tap { |r| r.created_at = artifical_created_at; r.save }
              end
            end

            # Create DayReports if Events occured that specific day
            #
            #

            day_scope       = BestBoyEvent.where(created_at: day.beginning_of_day..day.end_of_day)
                                          .where(owner_type: owner_type, event: event, event_source: source)
                                          .order('created_at DESC')
            daily_occurrences = day_scope.count
            
            if daily_occurrences > 0
              if source.present?
                day_report_with_source = BestBoy::DayReport.create(
                  owner_type:      owner_type, 
                  event:           event, 
                  event_source:    source,
                  occurrences:     daily_occurrences,
                  month_report_id: month_report_id_for(day.year, owner_type, source, event)
                ).tap { |r| r.created_at = day_scope.first.created_at; r.save }
              end

              day_report_without_source = BestBoy::DayReport.create(
                owner_type:      owner_type, 
                event:           event, 
                event_source:    nil,
                occurrences:     daily_occurrences,
                month_report_id: month_report_id_for(day.year, owner_type, source, event)
              ).tap { |r| r.created_at = day_scope.first.created_at; r.save }
            end
          end
        end
      end

      flush
    end

    puts ""
    puts ""
    puts "> Reports recovered. Done!"
    puts ""
  end
end
