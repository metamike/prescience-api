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

ActiveRecord::Schema.define(version: 20150127150512) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "expense_account_activities", force: :cascade do |t|
    t.integer  "expense_account_id"
    t.string   "month"
    t.decimal  "amount",             precision: 9, scale: 2
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "expense_account_activities", ["expense_account_id"], name: "index_expense_account_activities_on_expense_account_id", using: :btree

  create_table "expense_accounts", force: :cascade do |t|
    t.integer  "scenario_id"
    t.string   "name"
    t.string   "starting_month"
    t.decimal  "starting_amount",    precision: 9, scale: 2
    t.integer  "year_interval"
    t.string   "month_coefficients"
    t.decimal  "rate_of_increase",   precision: 4, scale: 3
    t.string   "increase_schedule"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "expense_accounts", ["scenario_id"], name: "index_expense_accounts_on_scenario_id", using: :btree

  create_table "income_account_activities", force: :cascade do |t|
    t.integer  "income_account_id"
    t.string   "month"
    t.decimal  "gross",             precision: 9, scale: 2
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  add_index "income_account_activities", ["income_account_id"], name: "index_income_account_activities_on_income_account_id", using: :btree

  create_table "income_accounts", force: :cascade do |t|
    t.integer  "scenario_id"
    t.string   "name"
    t.string   "starting_month"
    t.decimal  "annual_salary",  precision: 8, scale: 2
    t.string   "annual_raise"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  create_table "savings_account_activities", force: :cascade do |t|
    t.integer  "savings_account_id"
    t.string   "month"
    t.decimal  "interest",           precision: 9,  scale: 2
    t.decimal  "ending_balance",     precision: 11, scale: 2
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  add_index "savings_account_activities", ["savings_account_id"], name: "index_savings_account_activities_on_savings_account_id", using: :btree

  create_table "savings_accounts", force: :cascade do |t|
    t.integer  "scenario_id"
    t.integer  "income_account_id"
    t.string   "starting_month"
    t.decimal  "starting_balance",      precision: 9, scale: 2
    t.string   "monthly_interest_rate"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
  end

  add_index "savings_accounts", ["income_account_id"], name: "index_savings_accounts_on_income_account_id", using: :btree

  create_table "scenarios", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
