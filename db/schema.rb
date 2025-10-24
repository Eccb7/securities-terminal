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

ActiveRecord::Schema[8.0].define(version: 2025_10_24_133625) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "alert_events", force: :cascade do |t|
    t.bigint "alert_rule_id", null: false
    t.string "severity"
    t.jsonb "payload"
    t.boolean "resolved"
    t.datetime "resolved_at"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_rule_id"], name: "index_alert_events_on_alert_rule_id"
  end

  create_table "alert_rules", force: :cascade do |t|
    t.string "name"
    t.string "rule_type"
    t.string "severity"
    t.jsonb "expression"
    t.boolean "enabled"
    t.bigint "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_alert_rules_on_organization_id"
  end

  create_table "audit_logs", force: :cascade do |t|
    t.bigint "actor_id", null: false
    t.string "action", null: false
    t.string "target_type"
    t.integer "target_id"
    t.jsonb "payload", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_audit_logs_on_actor_id"
    t.index ["created_at"], name: "index_audit_logs_on_created_at"
    t.index ["target_type", "target_id"], name: "index_audit_logs_on_target_type_and_target_id"
  end

  create_table "exchanges", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "timezone"
    t.time "market_open"
    t.time "market_close"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "market_quotes", force: :cascade do |t|
    t.bigint "security_id", null: false
    t.decimal "bid"
    t.decimal "ask"
    t.decimal "last_price"
    t.bigint "volume"
    t.decimal "high"
    t.decimal "low"
    t.decimal "open"
    t.decimal "close"
    t.datetime "timestamp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["security_id"], name: "index_market_quotes_on_security_id"
  end

  create_table "news_items", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.string "source"
    t.datetime "published_at"
    t.bigint "security_id", null: false
    t.jsonb "tags"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["security_id"], name: "index_news_items_on_security_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "security_id", null: false
    t.string "side"
    t.string "order_type"
    t.decimal "price"
    t.integer "quantity"
    t.integer "filled_quantity"
    t.string "status"
    t.datetime "placed_at"
    t.datetime "executed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["security_id"], name: "index_orders_on_security_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.integer "admin_user_id"
    t.jsonb "settings"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "portfolios", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "organization_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_portfolios_on_organization_id"
    t.index ["user_id"], name: "index_portfolios_on_user_id"
  end

  create_table "positions", force: :cascade do |t|
    t.bigint "portfolio_id", null: false
    t.bigint "security_id", null: false
    t.integer "quantity"
    t.decimal "avg_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["portfolio_id"], name: "index_positions_on_portfolio_id"
    t.index ["security_id"], name: "index_positions_on_security_id"
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

  create_table "watchlist_items", force: :cascade do |t|
    t.bigint "watchlist_id", null: false
    t.bigint "security_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["security_id"], name: "index_watchlist_items_on_security_id"
    t.index ["watchlist_id"], name: "index_watchlist_items_on_watchlist_id"
  end

  create_table "watchlists", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_watchlists_on_user_id"
  end

  add_foreign_key "alert_events", "alert_rules"
  add_foreign_key "alert_rules", "organizations"
  add_foreign_key "audit_logs", "users", column: "actor_id"
  add_foreign_key "market_quotes", "securities"
  add_foreign_key "news_items", "securities"
  add_foreign_key "orders", "securities"
  add_foreign_key "orders", "users"
  add_foreign_key "portfolios", "organizations"
  add_foreign_key "portfolios", "users"
  add_foreign_key "positions", "portfolios"
  add_foreign_key "positions", "securities"
  add_foreign_key "securities", "exchanges"
  add_foreign_key "users", "organizations"
  add_foreign_key "watchlist_items", "securities"
  add_foreign_key "watchlist_items", "watchlists"
  add_foreign_key "watchlists", "users"
end
