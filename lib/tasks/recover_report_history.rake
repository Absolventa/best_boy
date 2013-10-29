namespace :best_boy do
  desc "Creates consistent DayReport and MonthReport structure for given events"
  task :recover_report_history  => :environment do 
    unreported = BestBoyEvent.where(reported: false)

    puts "" 
    puts "=================================================================="
    puts "= Creating missing reports for #{unreported.count} events in steps of 1000 records ="
    puts "=================================================================="
    puts ""

    unreported.find_in_batches do |batch|
      batch.each do |event|
        event_month_scope = BestBoy::MonthReport.where(eventable_type: event.owner_type, event_type: event.event)
        event_day_scope = BestBoy::DayReport.where(eventable_type: event.owner_type, event_type: event.event)

        # care for a MonthReport WITHOUT source
        #
        # 

        month_report = event_month_scope.where(event_source: nil).month(event.created_at.month, event.created_at.year).first
        if month_report.nil?
          month_report = event_month_scope.new.tap { |r| r.created_at = event.created_at; r.save! }
        end 
        month_report.increment!(:occurences)
        
        # care for a DayReport WITHOUT source
        #
        #
         
        day_report = event_day_scope.where(event_source: nil).created_on(event.created_at).first  
        if day_report.nil?
          day_report = event_day_scope.new(month_report_id: month_report.id).tap { |r| r.created_at = event.created_at; r.save! }       
        end  
        day_report.increment!(:occurences)
        
        if event.event_source?
          
          # care for a MonthReport WITH source
          #
          #  

          month_report_with_source = event_month_scope.where(event_source: event.event_source).month(event.created_at.month, event.created_at.year).first
          if month_report_with_source.nil?
            month_report_with_source = event_month_scope.new(event_source: event.event_source).tap { |r| r.created_at = event.created_at; r.save! }
          end
          month_report_with_source.increment!(:occurences)
          
          # care for a DayReport WITH source
          #
          #
           
          day_report_with_source = event_day_scope.where(event_source: event.event_source).created_on(event.created_at).first  
          if day_report_with_source.nil?
            day_report_with_source = event_day_scope.new(event_source: event.event_source, month_report_id: month_report_with_source.id).tap { |r| r.created_at = event.created_at; r.save! }
          end
          day_report_with_source.increment!(:occurences)
        end
       
        event.update_column(:reported, true)
      end
      print "."
      STDOUT.flush
    end
    puts ""
    puts "Done!"
  end
end
