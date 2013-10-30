class CreateReports < ActiveRecord::Migration
  def self.up
    create_table :day_reports, :force => true do |t|
      t.string  :eventable_type
      t.string  :event_type
      t.integer :month_report_id
      t.integer :occurrences, default: 0
      t.timestamps
    end
    create_table :month_reports, :force => true do |t|
      t.string  :eventable_type
      t.string  :event_type
      t.integer :occurrences, default: 0
      t.timestamps
    end

    add_index :day_reports, :eventable_type
    add_index :day_reports, :created_at
    add_index :month_reports, :eventable_type
    add_index :month_reports, :created_at
  end

  def self.down
    drop_table :month_reports
    drop_table :day_reports
  end
end
