class AddEventSourceToBestBoyEventsTable < ActiveRecord::Migration
  def self.up
    add_column :best_boy_events, :event_source, :string
    add_index :best_boy_events, :event_source
  end

  def self.down
    remove_index :best_boy_events, :event_source
    remove_column :best_boy_events, :event_source
  end
end