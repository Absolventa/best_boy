# require 'rubygems'
# require 'bundler'
# require 'active_record'
# require 'active_support'
# require "best_boy/models/active_record/best_boy_event.rb"
# require "best_boy/models/active_record/best_boy/eventable.rb"
# require "best_boy/models/active_record/best_boy_day_report.rb"
# require "best_boy/models/active_record/best_boy_month_report.rb"
# require "best_boy/controllers/best_boy_controller.rb"
# require 'rspec'
# require 'rspec/autorun'
# require 'shoulda'

# root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
# ActiveRecord::Base.establish_connection(
#   :adapter => "sqlite3",
#   :database => "#{root}/db/bestboy.db"
# )
# ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS 'examples'")
# ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS 'best_boy_events'")
# ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS 'best_boy_day_reports'")
# ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS 'best_boy_month_reports'")
# ActiveRecord::Schema.define do
#   self.verbose = false

#   create_table :best_boy_events, :force => true do |t|
#     t.integer :owner_id
#     t.string :owner_type
#     t.string :event
#     t.string :event_source
#     t.timestamps
#   end
#   add_index :best_boy_events, :owner_id
#   add_index :best_boy_events, :owner_type
#   add_index :best_boy_events, [:owner_id, :owner_type]
#   add_index :best_boy_events, :event

#   create_table :best_boy_day_reports, :force => true do |t|
#     t.string  :owner_type
#     t.string  :event
#     t.string  :event_source
#     t.integer :month_report_id
#     t.integer :occurrences, default: 0
#     t.timestamps
#   end
#   create_table :best_boy_month_reports, :force => true do |t|
#     t.string  :owner_type
#     t.string  :event
#     t.string  :event_source
#     t.integer :occurrences, default: 0
#     t.timestamps
#   end

#   add_index :best_boy_day_reports, :created_at
#   add_index :best_boy_month_reports, :created_at

#   create_table :examples, :force => true do |t|
#     t.timestamps
#   end
# end

# ActiveRecord::Base.send(:include, BestBoy::Eventable)

# RSpec.configure do |config|
#   config.mock_with :rspec
#   config.include BestBoyController::InstanceMethods
# end

# Rspec Setup for rails engines accoring to http://viget.com/extend/rails-engine-testing-with-rspec-capybara-and-factorygirl

# This file is copied to spec/ when you run 'rails generate rspec:install'

ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require 'rspec/rails'
require 'shoulda'

Rails.backtrace_cleaner.remove_silencers!

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false
end

class Example < ActiveRecord::Base
  has_a_best_boy
end
