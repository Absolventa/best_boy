# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150610155251) do

  create_table "best_boy_day_reports", force: :cascade do |t|
    t.string "owner_type"
    t.string "event"
    t.string "event_source"
    t.integer "occurrences"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_best_boy_day_reports_on_created_at"
    t.index ["owner_type", "event", "event_source"], name: "index_best_boy_day_reports_aggregated_columns"
  end

  create_table "best_boy_events", force: :cascade do |t|
    t.integer "owner_id"
    t.string "owner_type"
    t.string "event"
    t.string "event_source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event"], name: "index_best_boy_events_on_event"
    t.index ["event_source"], name: "index_best_boy_events_on_event_source"
    t.index ["owner_id", "owner_type"], name: "index_best_boy_events_on_owner_id_and_owner_type"
    t.index ["owner_id"], name: "index_best_boy_events_on_owner_id"
    t.index ["owner_type"], name: "index_best_boy_events_on_owner_type"
  end

  create_table "test_resources", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
