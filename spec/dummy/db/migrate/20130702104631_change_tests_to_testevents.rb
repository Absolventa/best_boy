class ChangeTestsToTestevents < ActiveRecord::Migration
  def change
    rename_table :tests, :test_events
  end
end
