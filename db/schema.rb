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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120920215218) do

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.string   "website"
    t.string   "support_email"
    t.string   "phone_number"
    t.string   "address_line_1"
    t.string   "address_line_2"
    t.string   "postal_code"
    t.string   "state"
    t.string   "country"
    t.integer  "admin_id"
    t.string   "logo"
    t.string   "logo_large"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "companies", ["name"], :name => "index_companies_on_name", :unique => true

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.boolean  "admin",           :default => false
    t.boolean  "create_access",   :default => false
    t.boolean  "write_access",    :default => false
    t.integer  "company_id"
    t.integer  "district_id"
    t.string   "location"
    t.string   "position_title"
    t.string   "phone_number"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.string   "password_digest"
    t.boolean  "elephant_admin",  :default => false
    t.string   "remember_token"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

end
