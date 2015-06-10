class CreateTestEvents < ActiveRecord::Migration
  def change
    create_table :test_events do |t|
      t.timestamps
    end
  end
end
