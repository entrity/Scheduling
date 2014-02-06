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

ActiveRecord::Schema.define(version: 20140205030007) do

  create_table "activities", force: true do |t|
    t.integer  "activity_factory_id"
    t.string   "name"
    t.text     "description"
    t.integer  "vendor_id"
    t.string   "vendor_name"
    t.datetime "start"
    t.datetime "finish"
    t.integer  "bookings_available",                          default: 0
    t.decimal  "price",               precision: 6, scale: 2, default: 0.0
    t.boolean  "deleted",                                     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "activity_factories", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "vendor_id"
    t.string   "vendor_name"
    t.date     "start_date"
    t.time     "start_time"
    t.integer  "duration"
    t.date     "end_date"
    t.integer  "days_of_week"
    t.integer  "days_of_month"
    t.integer  "months_of_year"
    t.integer  "weeks_of_month"
    t.integer  "bookings_available",                         default: 0
    t.decimal  "price",              precision: 6, scale: 2, default: 0.0
    t.boolean  "deleted",                                    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
