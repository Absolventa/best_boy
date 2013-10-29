class AddReportedToBestBoyEvents < ActiveRecord::Migration
  def self.up
    add_column :best_boy_events, :reported, :boolean, default: false
  end

  def self.down
    remove_column :best_boy_events, :reported
  end
end
