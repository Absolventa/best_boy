class CreateReports < ActiveRecord::Migration
  def self.up
    create_table :best_boy_day_reports, :force => true do |t|
      t.string  :owner_type
      t.string  :event
      t.string  :event_source
      t.integer :month_report_id
      t.integer :occurrences, default: 0
      t.timestamps
    end
    create_table :best_boy_month_reports, :force => true do |t|
      t.string  :owner_type
      t.string  :event
      t.string  :event_source
      t.integer :occurrences, default: 0
      t.timestamps
    end

    add_index :best_boy_day_reports, :owner_type
    add_index :best_boy_day_reports, :created_at
    add_index :best_boy_day_reports, :event_source
    add_index :best_boy_month_reports, :owner_type
    add_index :best_boy_month_reports, :created_at
    add_index :best_boy_month_reports, :event_source
  end

  def self.down
    drop_table :best_boy_month_reports
    drop_table :best_boy_day_reports
  end
end
