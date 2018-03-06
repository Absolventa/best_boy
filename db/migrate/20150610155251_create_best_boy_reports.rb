class CreateBestBoyReports < ActiveRecord::Migration[5.1]
  def change
    create_table :best_boy_day_reports do |t|
      t.string   :owner_type
      t.string   :event
      t.string   :event_source
      t.integer  :month_report_id
      t.integer  :occurrences
      t.timestamps
    end

    add_index :best_boy_day_reports, :created_at
    add_index :best_boy_day_reports, :month_report_id
    add_index :best_boy_day_reports, [:owner_type, :event, :event_source], name: "index_best_boy_day_reports_aggregated_columns"


    create_table :best_boy_month_reports do |t|
      t.string   :owner_type
      t.string   :event
      t.string   :event_source
      t.integer  :occurrences, default: 0
      t.timestamps
    end

    add_index :best_boy_month_reports, :created_at
    add_index :best_boy_month_reports, [:owner_type, :event, :event_source], name: "index_best_boy_month_reports_aggregated_columns"
  end
end
