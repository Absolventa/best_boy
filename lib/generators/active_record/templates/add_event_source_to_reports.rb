class AddEventSourceToReports < ActiveRecord::Migration
  def self.up
    add_column :month_reports, :event_source, :string
    add_column :day_reports,   :event_source, :string

    add_index :month_reports, :event_source
    add_index :day_reports,   :event_source
  end

  def self.down
    remove_index  :month_reports,  :event_source
    remove_index  :day_reports,    :event_source
    remove_column :month_reports,  :event_source
    remove_column :day_reports,    :event_source
  end
end
