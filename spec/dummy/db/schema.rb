# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20131104114025) do

  create_table "best_boy_day_reports", force: true do |t|
    t.string   "owner_type"
    t.string   "event"
    t.string   "event_source"
    t.integer  "month_report_id"
    t.integer  "occurrences",     default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "best_boy_day_reports", ["created_at"], name: "index_best_boy_day_reports_on_created_at"
  add_index "best_boy_day_reports", ["event_source"], name: "index_best_boy_day_reports_on_event_source"
  add_index "best_boy_day_reports", ["owner_type"], name: "index_best_boy_day_reports_on_owner_type"

  create_table "best_boy_events", force: true do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "event"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "event_source"
  end

  add_index "best_boy_events", ["event"], name: "index_best_boy_events_on_event"
  add_index "best_boy_events", ["event_source"], name: "index_best_boy_events_on_event_source"
  add_index "best_boy_events", ["owner_id", "owner_type"], name: "index_best_boy_events_on_owner_id_and_owner_type"
  add_index "best_boy_events", ["owner_type"], name: "index_best_boy_events_on_owner_type"

  create_table "best_boy_month_reports", force: true do |t|
    t.string   "owner_type"
    t.string   "event"
    t.string   "event_source"
    t.integer  "occurrences",  default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "best_boy_month_reports", ["created_at"], name: "index_best_boy_month_reports_on_created_at"
  add_index "best_boy_month_reports", ["event_source"], name: "index_best_boy_month_reports_on_event_source"
  add_index "best_boy_month_reports", ["owner_type"], name: "index_best_boy_month_reports_on_owner_type"

  create_table "test_events", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
