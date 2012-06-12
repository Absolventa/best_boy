class CreateBestBoyEvents < ActiveRecord::Migration
  def self.up
    create_table :best_boy_events, :force => true do |t|
      t.integer :owner_id
      t.string :owner_type
      t.string :event
      t.timestamps
    end
    add_index :best_boy_events, :owner_id
    add_index :best_boy_events, :owner_type
    add_index :best_boy_events, [:owner_id, :owner_type]
    add_index :best_boy_events, :event
  end

  def self.down
    drop_table :best_boy_events
  end
end