# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2023_09_02_004214) do

  create_table "analysis_results", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "jan_code"
    t.string "product_name"
    t.integer "sales"
    t.decimal "cumulative_sales", precision: 10
    t.decimal "cumulative_percentage", precision: 10
    t.string "classification"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "analysis_session_id", null: false
    t.index ["analysis_session_id"], name: "index_analysis_results_on_analysis_session_id"
    t.index ["user_id"], name: "index_analysis_results_on_user_id"
  end

  create_table "analysis_sessions", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_analysis_sessions_on_user_id"
  end

  create_table "items", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "jan_code", null: false
    t.string "product_name", null: false
    t.integer "sales", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["jan_code"], name: "index_items_on_jan_code", unique: true
    t.index ["user_id"], name: "index_items_on_user_id"
  end

  create_table "users", charset: "utf8mb3", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "analysis_results", "users"
  add_foreign_key "analysis_sessions", "users"
  add_foreign_key "items", "users"
end
