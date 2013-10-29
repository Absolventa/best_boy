require 'rubygems'
require 'bundler/setup'
require 'rake'
require 'rspec/core'
require 'rspec/core/rake_task'
require 'active_record'
require 'active_support'
require "best_boy/models/active_record/best_boy_event.rb"
require "best_boy/models/active_record/best_boy/eventable.rb"
require "best_boy/models/active_record/best_boy_day_report.rb"
require "best_boy/models/active_record/best_boy_month_report.rb"
require "best_boy/controllers/best_boy_controller.rb"

Bundler::GemHelper.install_tasks
RSpec::Core::RakeTask.new(:spec)
task :default => :spec

# desc: Creates consistent DayReport and MonthReport structure for given events
task :recover_report_history do 

  ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3",
    :database => "spec/dummy/db/development.sqlite3"
    #:database => "db/bestboy.db"
  )

  ActiveRecord::Base.send(:include, BestBoy::Eventable)

  puts "=========================="
  puts "= Loading BBEvents ...   ="
  puts "=========================="
  puts "" 
  puts ""
  scope = BestBoyEvent.order('created_at ASC')  
  puts "> Loaded " << scope.count.to_s  << " Events."
  puts ""
 
  puts "==============================="
  puts "= Creating missing reports... ="
  puts "==============================="
  puts ""
  puts "(Go and grab a coffee!)"
  puts ""
  # find_each / find_in_batches do  |group|    group.each do |event| ... 

  unreported = scope.where(reported: false)

  unreported.each do |event|
    month_report = BestBoy::MonthReport.where(eventable_type: event.owner_type, event_type: event).month(event.created_at.month, event.created_at.year).first
    if month_report.present?
      puts "> Found existing MonthReport for Event#" << event.to_param << ". Will increase occurence counter."
      month_report.increment(:occurences)
      puts month_report.save ? "> success!" : "> Oouch! Can't save updated MonthReport."
    else
      puts "> No MonthReport for Event#" << event.to_param << ". Creating..."
      month_report = BestBoy::MonthReport.create(eventable_type: event.owner_type, event_type: event).tap { |r| r.created_at = event.created_at }

      month_report.increment(:occurences)
      puts month_report.save ? "> success!" : "> Oouch! Can't save this brand-new MonthReport!"
    end
     
    day_report = BestBoy::DayReport.where(eventable_type: event.owner_type, event_type: event).created_on(event.created_at).first.present?  
    if day_report.present?
      puts "> Found existing DayReport for Event#" << event.to_param << ". Will increase occurence counter."
      
      day_report.increment(:occurences)
      puts day_report.save ? "> success!" : "> Oooops. Can't save updated DayReport!" 
    else
      puts "> No DayReport for Event#" << event.to_param << ". Creating..."
      day_report = BestBoy::DayReport.create(eventable_type: event.owner_type, event_type: event, month_report_id: month_report.id).tap { |r| r.created_at = event.created_at }
     
      day_report.increment(:occurences)
      puts day_report.save ? "> success!" : "> Ooops. Can't save this brand-new DayReport!"
    end 
  
    event.reported = true
    puts event.save ? "successfully reported Event." : "Oh: Can't save event as reported!"
  end
  puts ""
  puts "====================="
  puts "= Done! Goodbye...  ="
  puts "====================="
end
