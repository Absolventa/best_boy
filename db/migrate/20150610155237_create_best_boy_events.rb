class CreateBestBoyEvents < ActiveRecord::Migration
  def change
    create_table :best_boy_events do |t|
      t.integer  :owner_id
      t.string   :owner_type
      t.string   :event
      t.string   :event_source
      t.timestamps
    end

    add_index :best_boy_events, :event
    add_index :best_boy_events, :event_source
    add_index :best_boy_events, [:owner_id, :owner_type]
    add_index :best_boy_events, :owner_id
    add_index :best_boy_events, :owner_type
  end
end
