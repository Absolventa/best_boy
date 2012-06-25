module ActiveRecord
  module Generators
    class BestBoyGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      source_root File.join(File.dirname(__FILE__), 'templates')

      def self.next_migration_number(dirname)
        sleep 1
        if ActiveRecord::Base.timestamped_migrations
          Time.now.utc.strftime("%Y%m%d%H%M%S")
        else
          "%.3d" % (current_migration_number(dirname) + 1)
        end
      end

      def create_migration_file
        migration_template 'create_best_boy_events_table.rb', 'db/migrate/create_best_boy_events_table.rb'
        migration_template 'add_event_source_to_best_boy_events_table.rb', 'db/migrate/add_event_source_to_best_boy_events_table.rb'
      end
    end
  end
end
