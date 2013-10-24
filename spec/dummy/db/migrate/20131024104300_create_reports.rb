class CreateReports < ActiveRecord::Migration
  def self.up
    create_table :best_boy_day_reports, :force => true do |t|
      t.string  :eventable_type
      t.integer :eventable_id
      t.string  :event_type
      t.integer :month_report_id
      t.integer :occurences, default: 0
      t.timestamps
    end
    create_table :best_boy_month_reports, :force => true do |t|
      t.string  :eventable_type
      t.integer :eventable_id
      t.string  :event_type
      t.integer :occurences, default: 0
      t.timestamps
    end

    add_index :best_boy_day_reports, [:eventable_type, :eventable_id], name: 'bb_day'
    add_index :best_boy_day_reports, :created_at
    add_index :best_boy_month_reports, [:eventable_type, :eventable_id], name: 'bb_month'
    add_index :best_boy_month_reports, :created_at
  end

  def self.down
    drop_table :best_boy_month_reports
    drop_table :best_boy_day_reports
  end
end
