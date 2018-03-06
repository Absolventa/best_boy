class CreateTestResources < ActiveRecord::Migration[5.1]
  def change
    create_table :test_resources do |t|
      t.timestamps
    end
  end
end
