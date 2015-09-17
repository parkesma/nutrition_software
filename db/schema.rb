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

ActiveRecord::Schema.define(version: 20150914211405) do

  create_table "exercise_assignments", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "exercise_id"
    t.integer  "position"
    t.integer  "hrs_per_wk"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "exercise_assignments", ["exercise_id"], name: "index_exercise_assignments_on_exercise_id"
  add_index "exercise_assignments", ["user_id"], name: "index_exercise_assignments_on_user_id"

  create_table "exercises", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "description"
    t.float    "Kcal_per_kg_per_hr"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "category"
  end

  add_index "exercises", ["user_id"], name: "index_exercises_on_user_id"

  create_table "fat_measurements", force: :cascade do |t|
    t.integer  "user_id"
    t.float    "weight"
    t.float    "chest"
    t.float    "abdomen"
    t.float    "thigh"
    t.float    "tricep"
    t.float    "subscapular"
    t.float    "iliac_crest"
    t.float    "calf"
    t.float    "bicep"
    t.float    "lower_back"
    t.float    "neck"
    t.float    "measured_bf"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "bf_method"
    t.float    "midaxillary"
    t.float    "hip"
  end

  add_index "fat_measurements", ["user_id"], name: "index_fat_measurements_on_user_id"

  create_table "measurements", force: :cascade do |t|
    t.integer  "user_id"
    t.float    "weight"
    t.float    "body_fat"
    t.float    "chest"
    t.float    "waist"
    t.float    "rt_arm"
    t.float    "rt_forearm"
    t.float    "hips"
    t.float    "rt_thigh"
    t.float    "rt_calf"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "measurements", ["user_id"], name: "index_measurements_on_user_id"

  create_table "notes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "author_id"
    t.text     "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "notes", ["user_id"], name: "index_notes_on_user_id"

  create_table "relationships", force: :cascade do |t|
    t.integer  "sub_id"
    t.integer  "sup_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "relationships", ["sub_id", "sup_id"], name: "index_relationships_on_sub_id_and_sup_id", unique: true
  add_index "relationships", ["sub_id"], name: "index_relationships_on_sub_id"
  add_index "relationships", ["sup_id"], name: "index_relationships_on_sup_id"

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "password"
    t.string   "license"
    t.integer  "trainer_id"
    t.date     "expiration_date"
    t.boolean  "graduated",               default: false
    t.string   "website1"
    t.string   "website2"
    t.string   "first_name"
    t.string   "last_name"
    t.date     "starting_date"
    t.date     "date_of_birth"
    t.string   "gender"
    t.string   "home_address_1"
    t.string   "home_address_2"
    t.string   "home_city"
    t.string   "home_state"
    t.integer  "home_zip"
    t.string   "home_country"
    t.string   "work_address_1"
    t.string   "work_address_2"
    t.string   "email"
    t.string   "home_phone"
    t.string   "mobile_phone"
    t.string   "work_phone"
    t.string   "other_phone"
    t.float    "resting_heart_rate"
    t.float    "present_weight"
    t.float    "height"
    t.float    "desired_weight"
    t.float    "desired_body_fat"
    t.float    "measured_metabolic_rate"
    t.integer  "activity_index"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.boolean  "logged_in"
    t.string   "work_city"
    t.string   "work_state"
    t.integer  "work_zip"
    t.string   "work_country"
    t.string   "company"
    t.float    "present_body_fat"
    t.string   "clothing"
  end

end
