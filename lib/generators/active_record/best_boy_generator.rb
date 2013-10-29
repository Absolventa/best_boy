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
        %w(create_best_boy_events_table.rb add_event_source_to_best_boy_events_table.rb create_reports.rb add_event_source_to_reports.rb).each do |migration_file|
          destination = "db/migrate/#{migration_file.sub(%r\.rb$\, '')}"
          if not self.class.migration_exists?(File.dirname(destination), File.basename(destination))
            migration_template migration_file, destination
          end
        end
      end
    end
  end
end
