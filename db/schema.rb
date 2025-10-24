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

ActiveRecord::Schema[8.0].define(version: 2025_10_24_133036) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "exchanges", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "timezone"
    t.time "market_open"
    t.time "market_close"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.integer "admin_user_id"
    t.jsonb "settings"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "securities", force: :cascade do |t|
    t.string "ticker", null: false
    t.string "name", null: false
    t.string "instrument_type", null: false
    t.string "currency", default: "KES"
    t.string "isin"
    t.integer "lot_size", default: 1
    t.string "status", default: "active"
    t.bigint "exchange_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exchange_id"], name: "index_securities_on_exchange_id"
    t.index ["isin"], name: "index_securities_on_isin", unique: true, where: "(isin IS NOT NULL)"
    t.index ["status"], name: "index_securities_on_status"
    t.index ["ticker"], name: "index_securities_on_ticker", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "name"
    t.integer "role", default: 0, null: false
    t.string "two_fa_secret"
    t.boolean "two_fa_enabled", default: false, null: false
    t.bigint "organization_id"
    t.boolean "trading_restricted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "securities", "exchanges"
  add_foreign_key "users", "organizations"
end
