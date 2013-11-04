namespace :best_boy do
  desc "Creates consistent DayReport and MonthReport structure for given events"
  task :recover_report_history  => :environment do 

    # helper methods
    #
    #

    def sanitized(source)
      source.nil? ? "nil" : source
    end

    def flush
      print "."
      STDOUT.flush
    end

    # Destroy all existing reports
    #
    #

    BestBoy::MonthReport.destroy_all
    BestBoy::DayReport.destroy_all

    puts ""
    puts "> All report data has been destroyed."
    puts ""

    owner_types             = BestBoyEvent.order(:owner_type).uniq.pluck(:owner_type)
    available_events        = {}
    available_event_sources = {}
    month_report_ids = {}

    owner_types.each do |owner_type|
      available_events.merge!(        { owner_type => BestBoyEvent.where(owner_type: owner_type).order(:event).uniq.pluck(:event) } )
      available_event_sources.merge!( { owner_type => BestBoyEvent.where(owner_type: owner_type).order(:event_source).uniq.pluck(:event_source) } ) # explicitly including nil
    end

    days = (BestBoyEvent.order('created_at ASC').first.created_at.to_date..BestBoyEvent.order('created_at ASC').last.created_at.to_date)

    puts "> Start creating new reports..."
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
                    eventable_type: owner_type, 
                    event_type:     event,
                    event_source:   source,
                    occurrences:    monthly_occurrences 
                  ).tap { |r| r.created_at = artifical_created_at; r.save }
                  
                  month_report_ids.merge!({  
                    artifical_created_at.year => {
                      owner_type => { 
                        sanitized(source) => { event => month_report_with_source.id } 
                      }
                    }
                  }) { |key, val1, val2| val1.merge!(val2) { |k,v1,v2| v1.merge!(v2) } }
                  
                  flush
                end

                month_report_without_source = BestBoy::MonthReport.create(
                  eventable_type: owner_type, 
                  event_type:     event,
                  event_source:   nil,
                  occurrences:    monthly_occurrences 
                ).tap { |r| r.created_at = artifical_created_at; r.save }
              
                month_report_ids.merge!({  
                  artifical_created_at.year => { 
                    owner_type => { 
                      sanitized(source) => { 
                        event => 
                          month_report_without_source.id 
                      } 
                    }
                  }
                }) { |key, val1, val2| val1.merge!(val2) { |k,v1,v2| v1.merge!(v2) } }
                
                flush
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
                  eventable_type:  owner_type, 
                  event_type:      event, 
                  event_source:    source,
                  occurrences:     daily_occurrences,
                  month_report_id: month_report_ids[day.year][owner_type][sanitized(source)][event]
                ).tap { |r| r.created_at = day_scope.first.created_at; r.save }
                flush
              end

              day_report_without_source = BestBoy::DayReport.create(
                eventable_type:  owner_type, 
                event_type:      event, 
                event_source:    nil,
                occurrences:     daily_occurrences,
                month_report_id: month_report_ids[day.year][owner_type][sanitized(source)][event]
              ).tap { |r| r.created_at = day_scope.first.created_at; r.save }
              flush
            end
          end
        end
      end
    end

    puts ""
    puts "> Reports recovered. Done!"
    puts ""
  end
end
