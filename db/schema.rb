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

ActiveRecord::Schema.define(version: 20131122160317) do

  create_table "customers", force: true do |t|
    t.string   "email",              default: "",    null: false
    t.string   "encrypted_password", default: "",    null: false
    t.string   "name",                               null: false
    t.string   "webpay_customer_id"
    t.string   "address",                            null: false
    t.boolean  "disabled",           default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "customers", ["email"], name: "index_customers_on_email", unique: true
  add_index "customers", ["webpay_customer_id"], name: "index_customers_on_webpay_customer_id", unique: true

  create_table "items", force: true do |t|
    t.string   "name",       null: false
    t.integer  "price",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sales", force: true do |t|
    t.integer  "customer_id"
    t.integer  "item_id"
    t.string   "webpay_charge_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sales", ["customer_id"], name: "index_sales_on_customer_id"
  add_index "sales", ["item_id"], name: "index_sales_on_item_id"

end
