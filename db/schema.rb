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

ActiveRecord::Schema.define(version: 20150616180412) do

  create_table "addresses", force: :cascade do |t|
    t.string   "address"
    t.integer  "zipcode"
    t.string   "city"
    t.string   "phone"
    t.integer  "country_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "addresses", ["country_id"], name: "index_addresses_on_country_id"

  create_table "authors", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.text     "biography"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "books", force: :cascade do |t|
    t.string   "title"
    t.text     "descirption"
    t.float    "price"
    t.integer  "books_in_stock"
    t.integer  "category_id"
    t.integer  "author_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "books", ["author_id"], name: "index_books_on_author_id"
  add_index "books", ["category_id"], name: "index_books_on_category_id"

  create_table "categories", force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "countries", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "credit_cards", force: :cascade do |t|
    t.string   "number"
    t.integer  "cvv"
    t.integer  "exp_month"
    t.integer  "exp_year"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "customer_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "credit_cards", ["customer_id"], name: "index_credit_cards_on_customer_id"

  create_table "customers", force: :cascade do |t|
    t.string   "email"
    t.string   "password"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "order_items", force: :cascade do |t|
    t.float    "price"
    t.integer  "quantity"
    t.integer  "book_id"
    t.integer  "order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orders", force: :cascade do |t|
    t.float    "total_price",         default: 0.0
    t.date     "completed_date"
    t.string   "state",               default: "in progress"
    t.integer  "credit_card_id"
    t.integer  "customer_id"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "billing_address_id"
    t.integer  "shipping_address_id"
  end

  add_index "orders", ["billing_address_id"], name: "index_orders_on_billing_address_id"
  add_index "orders", ["shipping_address_id"], name: "index_orders_on_shipping_address_id"

  create_table "ratings", force: :cascade do |t|
    t.text     "review"
    t.integer  "rate"
    t.integer  "customer_id"
    t.integer  "book_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

end
