namespace :best_boy do
  desc "Creates consistent structure of DayReports for a given set of events"
  task :recover_report_history, [:date]  => :environment do |t, args|

    next unless BestBoy::Event.any?

    # helper methods
    #
    #

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
      BestBoy::DayReport.where(created_at: start.beginning_of_day..Date.today.end_of_day).delete_all
    else
      BestBoy::DayReport.delete_all
    end

    puts ""
    puts "> Selected report data has been destroyed."
    puts ""

    owner_types             = BestBoy::Event.order(:owner_type).uniq.pluck(:owner_type)
    available_events        = {}
    available_event_sources = {}

    owner_types.each do |owner_type|
      available_events.merge!(        { owner_type => BestBoy::Event.where(owner_type: owner_type).order(:event).uniq.pluck(:event) } )
      available_event_sources.merge!( { owner_type => BestBoy::Event.where(owner_type: owner_type).order(:event_source).uniq.pluck(:event_source) } ) # explicitly including nil
    end

    start = BestBoy::Event.order('created_at ASC').first.created_at.to_date unless start.present?
    days  = (start..BestBoy::Event.order('created_at ASC').last.created_at.to_date)

    puts ""
    puts "> Start creating new reports for #{days.count} days ..."
    puts ""

    days.each do |day|
      owner_types.each do |owner_type|
        available_events[owner_type].each do |event|
          available_event_sources[owner_type].each do |source|

            base_scope = BestBoy::Event.where(owner_type: owner_type, event: event, event_source: source).order('created_at DESC')

            # Create DayReports if Events occured that specific day
            #
            #

            day_scope         = base_scope.where(created_at: day.beginning_of_day..day.end_of_day)
            daily_occurrences = day_scope.count

            if daily_occurrences > 0
              if source.present?
                day_report_with_source = BestBoy::DayReport.new
                day_report_with_source.owner_type = owner_type
                day_report_with_source.event = event
                day_report_with_source.event_source = source
                day_report_with_source.occurrences = daily_occurrences
                day_report_with_source.created_at = day_scope.first.created_at
                day_report_with_source.save!
              end

              day_report_without_source = BestBoy::DayReport.new
              day_report_without_source.owner_type = owner_type
              day_report_without_source.event = event
              day_report_without_source.event_source = nil
              day_report_without_source.occurrences = daily_occurrences
              day_report_without_source.created_at = day_scope.first.created_at
              day_report_without_source.save!
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
