require 'rubygems'
require 'bundler'
require 'active_record'
require 'active_support'
require "best_boy/models/active_record/best_boy_event.rb"
require "best_boy/models/active_record/best_boy/eventable.rb"
require "best_boy/models/active_record/best_boy_day_report.rb"
require "best_boy/models/active_record/best_boy_month_report.rb"
require "best_boy/controllers/best_boy_controller.rb"
require 'rspec'
require 'rspec/autorun'
require 'shoulda'

root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "#{root}/db/bestboy.db"
)
ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS 'examples'")
ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS 'best_boy_events'")
ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS 'best_boy_day_reports'")
ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS 'best_boy_month_reports'")
ActiveRecord::Schema.define do
  self.verbose = false

  create_table :best_boy_events, :force => true do |t|
    t.integer :owner_id
    t.string :owner_type
    t.string :event
    t.string :event_source
    t.timestamps
  end
  add_index :best_boy_events, :owner_id
  add_index :best_boy_events, :owner_type
  add_index :best_boy_events, [:owner_id, :owner_type]
  add_index :best_boy_events, :event

  create_table :day_reports, :force => true do |t|
    t.string  :eventable_type
    t.integer :eventable_id
    t.string  :event_type
    t.integer :month_report_id
    t.integer :occurences, default: 0
    t.timestamps
  end
  create_table :month_reports, :force => true do |t|
    t.string  :eventable_type
    t.integer :eventable_id
    t.string  :event_type
    t.integer :occurences, default: 0
    t.timestamps
  end

  add_index :day_reports, :created_at
  add_index :month_reports, :created_at

  puts "================"
  puts "reports created!"
  puts "================"

  create_table :examples, :force => true do |t|
    t.timestamps
  end
end

ActiveRecord::Base.send(:include, BestBoy::Eventable)

RSpec.configure do |config|
  config.mock_with :rspec
  config.include BestBoyController::InstanceMethods
end

class Dummy
end

class Example < ActiveRecord::Base
  has_a_best_boy
end
