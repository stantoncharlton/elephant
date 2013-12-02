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

ActiveRecord::Schema.define(:version => 20131202174052) do

  create_table "activities", :force => true do |t|
    t.integer  "company_id"
    t.integer  "user_id"
    t.integer  "activity_type"
    t.integer  "target_id"
    t.string   "target_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "metadata"
    t.integer  "job_id"
    t.string   "user_name"
  end

  add_index "activities", ["company_id"], :name => "index_activities_on_company_id"
  add_index "activities", ["job_id"], :name => "index_activities_on_job_id"
  add_index "activities", ["target_id", "target_type"], :name => "index_activities_on_target_id_and_target_type"
  add_index "activities", ["user_id"], :name => "index_activities_on_user_id"

  create_table "alerts", :force => true do |t|
    t.integer  "company_id"
    t.integer  "user_id"
    t.integer  "alert_type"
    t.integer  "target_id"
    t.string   "target_type"
    t.integer  "job_id"
    t.integer  "created_by_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.datetime "expiration"
  end

  add_index "alerts", ["company_id"], :name => "index_alerts_on_company_id"
  add_index "alerts", ["created_by_id"], :name => "index_alerts_on_created_by"
  add_index "alerts", ["job_id"], :name => "index_alerts_on_job_id"
  add_index "alerts", ["target_id", "target_type"], :name => "index_alerts_on_target_id_and_target_type"
  add_index "alerts", ["user_id"], :name => "index_alerts_on_user_id"

  create_table "api_keys", :force => true do |t|
    t.string   "access_token"
    t.integer  "user_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "bha_items", :force => true do |t|
    t.integer  "company_id"
    t.integer  "bha_id"
    t.integer  "tool_id"
    t.string   "tool_type"
    t.decimal  "inner_diameter"
    t.decimal  "outer_diameter"
    t.decimal  "length"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "ordering"
    t.integer  "up"
    t.integer  "down"
  end

  add_index "bha_items", ["bha_id"], :name => "index_bha_items_on_bha_id"
  add_index "bha_items", ["company_id"], :name => "index_bha_items_on_company_id"

  create_table "bhas", :force => true do |t|
    t.integer  "company_id"
    t.integer  "job_id"
    t.integer  "document_id"
    t.string   "name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "description"
  end

  add_index "bhas", ["company_id"], :name => "index_bhas_on_company_id"
  add_index "bhas", ["document_id"], :name => "index_bhas_on_document_id"

  create_table "clients", :force => true do |t|
    t.string   "name"
    t.integer  "company_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "country_id"
  end

  add_index "clients", ["company_id"], :name => "index_clients_on_company_id"

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
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.string   "vpn_range"
    t.boolean  "test_company",     :default => false
    t.boolean  "inventory_active", :default => true
    t.string   "city"
    t.integer  "minimum_work_day", :default => 8
    t.integer  "work_day_type",    :default => 1
  end

  add_index "companies", ["name"], :name => "index_companies_on_name", :unique => true

  create_table "conversation_memberships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "conversation_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "company_id"
  end

  add_index "conversation_memberships", ["conversation_id"], :name => "index_conversation_memberships_on_conversation_id"
  add_index "conversation_memberships", ["user_id", "conversation_id"], :name => "index_conversation_memberships_on_user_id_and_conversation_id"
  add_index "conversation_memberships", ["user_id"], :name => "index_conversation_memberships_on_user_id"

  create_table "conversations", :force => true do |t|
    t.integer  "company_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "conversations", ["company_id"], :name => "index_conversations_on_company_id"

  create_table "countries", :force => true do |t|
    t.string   "iso"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "districts", :force => true do |t|
    t.string   "name"
    t.integer  "company_id"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.string   "location"
    t.integer  "country_id"
    t.integer  "state_id"
    t.string   "address_line_1"
    t.string   "address_line_2"
    t.string   "postal_code"
    t.string   "phone_number"
    t.string   "city"
    t.string   "region"
    t.string   "support_email"
    t.string   "time_zone"
    t.integer  "master_district_id"
    t.boolean  "master",             :default => true
  end

  add_index "districts", ["company_id"], :name => "index_districts_on_company_id"
  add_index "districts", ["country_id"], :name => "index_districts_on_country_id"
  add_index "districts", ["master_district_id"], :name => "index_districts_on_master_district_id"
  add_index "districts", ["state_id"], :name => "index_districts_on_state_id"

  create_table "divisions", :force => true do |t|
    t.string   "name"
    t.integer  "company_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "divisions", ["company_id"], :name => "index_divisions_on_company_id"

  create_table "document_revisions", :force => true do |t|
    t.integer  "company_id"
    t.integer  "document_id"
    t.integer  "user_id"
    t.string   "user_name"
    t.string   "url"
    t.datetime "upload_date"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "document_shares", :force => true do |t|
    t.integer  "document_id"
    t.string   "email"
    t.string   "access_code"
    t.integer  "shared_by_id"
    t.integer  "job_id"
    t.integer  "forwarded_document_share"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.integer  "company_id"
  end

  add_index "document_shares", ["document_id", "email"], :name => "index_document_shares_on_document_id_and_email", :unique => true
  add_index "document_shares", ["document_id"], :name => "index_document_shares_on_document_id"
  add_index "document_shares", ["email"], :name => "index_document_shares_on_email"
  add_index "document_shares", ["forwarded_document_share"], :name => "index_document_shares_on_forwarded_document_share"
  add_index "document_shares", ["job_id"], :name => "index_document_shares_on_job_id"

  create_table "documents", :force => true do |t|
    t.integer  "job_template_id"
    t.integer  "job_id"
    t.string   "category"
    t.string   "name"
    t.string   "url"
    t.string   "status"
    t.boolean  "template",              :default => false
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.integer  "document_type",         :default => 0
    t.integer  "company_id"
    t.integer  "document_template_id"
    t.integer  "user_id"
    t.boolean  "read_only",             :default => false
    t.integer  "ordering",              :default => 0
    t.integer  "post_job_report_order"
    t.integer  "document_shares_count", :default => 0,     :null => false
    t.string   "user_name"
    t.integer  "primary_tool_id"
    t.integer  "access_level",          :default => 0
    t.integer  "owner_id"
    t.string   "owner_type"
  end

  add_index "documents", ["company_id"], :name => "index_documents_on_company_id"
  add_index "documents", ["document_template_id"], :name => "index_documents_on_document_template_id"
  add_index "documents", ["job_id"], :name => "index_documents_on_job_id"
  add_index "documents", ["job_template_id"], :name => "index_documents_on_job_template_id"
  add_index "documents", ["owner_id", "owner_type"], :name => "index_documents_on_owner_id_and_owner_type"
  add_index "documents", ["primary_tool_id"], :name => "index_documents_on_primary_tool_id"

  create_table "drilling_log_entries", :force => true do |t|
    t.integer  "company_id"
    t.integer  "document_id"
    t.integer  "job_id"
    t.integer  "user_id"
    t.string   "user_name"
    t.datetime "entry_at"
    t.decimal  "depth"
    t.integer  "activity_code"
    t.string   "comment"
    t.integer  "bha_id"
    t.decimal  "usage_hours"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "drilling_log_id"
  end

  add_index "drilling_log_entries", ["bha_id"], :name => "index_drilling_log_entries_on_bha_id"
  add_index "drilling_log_entries", ["company_id"], :name => "index_drilling_log_entries_on_company_id"
  add_index "drilling_log_entries", ["document_id"], :name => "index_drilling_log_entries_on_document_id"
  add_index "drilling_log_entries", ["drilling_log_id"], :name => "index_drilling_log_entries_on_drilling_log_id"
  add_index "drilling_log_entries", ["job_id"], :name => "index_drilling_log_entries_on_job_id"
  add_index "drilling_log_entries", ["user_id"], :name => "index_drilling_log_entries_on_user_id"

  create_table "drilling_logs", :force => true do |t|
    t.integer  "company_id"
    t.integer  "document_id"
    t.integer  "job_id"
    t.decimal  "rop"
    t.decimal  "total_drilled"
    t.decimal  "below_rotary"
    t.decimal  "slide_rop"
    t.decimal  "slide_footage"
    t.decimal  "slide_hours"
    t.decimal  "rotate_rop"
    t.decimal  "rotate_footage"
    t.decimal  "rotate_hours"
    t.decimal  "circulation_hours"
    t.decimal  "ream_hours"
    t.decimal  "rotary_hours_pct"
    t.decimal  "slide_hours_pct"
    t.decimal  "rotary_footage_pct"
    t.decimal  "slide_footage_pct"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "drilling_logs", ["company_id"], :name => "index_drilling_logs_on_company_id"
  add_index "drilling_logs", ["document_id"], :name => "index_drilling_logs_on_document_id"
  add_index "drilling_logs", ["job_id"], :name => "index_drilling_logs_on_job_id"

  create_table "drilling_properties", :force => true do |t|
    t.integer  "company_id"
    t.integer  "user_id"
    t.integer  "document_id"
    t.decimal  "wob"
    t.decimal  "rot_wt"
    t.decimal  "pu_wt"
    t.decimal  "so_wt"
    t.decimal  "spp"
    t.decimal  "flow"
    t.decimal  "spm"
    t.decimal  "rot_rpm"
    t.decimal  "mot_rpm"
    t.decimal  "incl_in"
    t.decimal  "azm_in"
    t.decimal  "incl_out"
    t.decimal  "azm_out"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "drilling_properties", ["document_id"], :name => "index_drilling_properties_on_document_id"

  create_table "dynamic_fields", :force => true do |t|
    t.integer  "job_template_id"
    t.integer  "job_id"
    t.string   "name",                                         :null => false
    t.string   "value"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.boolean  "template"
    t.integer  "company_id"
    t.boolean  "priority"
    t.integer  "dynamic_field_template_id"
    t.integer  "value_type",                :default => 1
    t.integer  "default_value_type",        :default => 0
    t.integer  "ordering",                  :default => 0
    t.boolean  "predefined",                :default => false
    t.boolean  "optional",                  :default => false
  end

  add_index "dynamic_fields", ["company_id"], :name => "index_dynamic_fields_on_company_id"
  add_index "dynamic_fields", ["dynamic_field_template_id"], :name => "index_dynamic_fields_on_dynamic_field_template_id"
  add_index "dynamic_fields", ["job_id"], :name => "index_dynamic_fields_on_job_id"
  add_index "dynamic_fields", ["job_template_id"], :name => "index_dynamic_fields_on_job_template_id"
  add_index "dynamic_fields", ["name"], :name => "index_dynamic_fields_on_name"

  create_table "failures", :force => true do |t|
    t.string   "text"
    t.integer  "company_id"
    t.string   "reference"
    t.integer  "product_line_id"
    t.integer  "job_template_id"
    t.integer  "job_id"
    t.boolean  "template",                   :default => false
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.integer  "failure_master_template_id"
  end

  add_index "failures", ["company_id"], :name => "index_failures_on_company_id"
  add_index "failures", ["failure_master_template_id"], :name => "index_failures_on_failure_template_id"
  add_index "failures", ["job_id"], :name => "index_failures_on_job_id"
  add_index "failures", ["job_template_id"], :name => "index_failures_on_job_template_id"
  add_index "failures", ["product_line_id"], :name => "index_failures_on_product_line_id"

  create_table "fields", :force => true do |t|
    t.string   "name"
    t.integer  "company_id"
    t.integer  "district_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "location"
    t.string   "county"
    t.integer  "country_id"
    t.integer  "state_id"
  end

  add_index "fields", ["company_id"], :name => "index_fields_on_company_id"
  add_index "fields", ["district_id"], :name => "index_fields_on_district_id"

  create_table "issues", :force => true do |t|
    t.integer  "company_id"
    t.integer  "job_id"
    t.integer  "failure_id"
    t.integer  "status"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "issues", ["company_id"], :name => "index_issues_on_company_id"
  add_index "issues", ["failure_id"], :name => "index_issues_on_failure_id"
  add_index "issues", ["job_id"], :name => "index_issues_on_job_id"

  create_table "job_logs", :force => true do |t|
    t.integer  "company_id"
    t.integer  "document_id"
    t.integer  "job_id"
    t.integer  "user_id"
    t.string   "comment",     :limit => 500
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.datetime "entry_at"
    t.string   "user_name"
  end

  add_index "job_logs", ["company_id"], :name => "index_job_logs_on_company_id"
  add_index "job_logs", ["document_id"], :name => "index_job_logs_on_document_id"
  add_index "job_logs", ["job_id"], :name => "index_job_logs_on_job_id"
  add_index "job_logs", ["user_id"], :name => "index_job_logs_on_user_id"

  create_table "job_memberships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "job_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "job_role_id"
    t.string   "user_name"
    t.integer  "company_id"
    t.string   "phone_number"
    t.string   "email"
    t.boolean  "external_user", :default => false
    t.integer  "shift_type"
  end

  add_index "job_memberships", ["job_id"], :name => "index_job_memberships_on_job_id"
  add_index "job_memberships", ["user_id"], :name => "index_job_memberships_on_user_id"

  create_table "job_note_comments", :force => true do |t|
    t.integer  "job_id"
    t.integer  "job_note_id"
    t.integer  "user_id"
    t.string   "text",        :limit => 1000
    t.integer  "company_id"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.string   "user_name"
  end

  add_index "job_note_comments", ["company_id"], :name => "index_job_note_comments_on_company_id"
  add_index "job_note_comments", ["job_id"], :name => "index_job_note_comments_on_job_id"
  add_index "job_note_comments", ["job_note_id"], :name => "index_job_note_comments_on_job_note_id"
  add_index "job_note_comments", ["user_id"], :name => "index_job_note_comments_on_user_id"

  create_table "job_notes", :force => true do |t|
    t.integer  "job_id"
    t.integer  "user_id"
    t.integer  "company_id"
    t.string   "text",         :limit => 2000
    t.integer  "note_type"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "assign_to_id"
    t.string   "user_name"
    t.integer  "issue_id"
    t.integer  "owner_id"
    t.string   "owner_type"
  end

  add_index "job_notes", ["owner_id", "owner_type"], :name => "index_job_notes_on_owner_id_and_owner_type"

  create_table "job_processes", :force => true do |t|
    t.integer  "job_id"
    t.integer  "company_id"
    t.integer  "event_type"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "job_processes", ["company_id"], :name => "index_job_processes_on_company_id"
  add_index "job_processes", ["job_id"], :name => "index_job_processes_on_job_id"
  add_index "job_processes", ["user_id"], :name => "index_job_processes_on_user_id"

  create_table "job_templates", :force => true do |t|
    t.string   "name"
    t.integer  "product_line_id"
    t.integer  "company_id"
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
    t.string   "description",       :limit => 2000
    t.boolean  "track_accessories",                 :default => false
  end

  add_index "job_templates", ["company_id"], :name => "index_job_templates_on_company_id"
  add_index "job_templates", ["product_line_id"], :name => "index_job_templates_on_product_line_id"

  create_table "job_times", :force => true do |t|
    t.integer  "company_id"
    t.integer  "job_id"
    t.integer  "user_id"
    t.datetime "time_for"
    t.integer  "status"
    t.decimal  "hours"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "job_times", ["company_id"], :name => "index_job_times_on_company_id"
  add_index "job_times", ["job_id"], :name => "index_job_times_on_job_id"
  add_index "job_times", ["user_id"], :name => "index_job_times_on_user_id"

  create_table "jobs", :force => true do |t|
    t.integer  "job_template_id"
    t.integer  "field_id"
    t.integer  "well_id"
    t.integer  "district_id"
    t.integer  "client_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.integer  "company_id"
    t.integer  "status"
    t.datetime "close_date"
    t.integer  "rating"
    t.integer  "failures_count",        :default => 0
    t.integer  "job_memberships_count", :default => 0
    t.string   "job_number"
  end

  add_index "jobs", ["client_id"], :name => "index_jobs_on_client_id"
  add_index "jobs", ["company_id"], :name => "index_jobs_on_company_id"
  add_index "jobs", ["district_id"], :name => "index_jobs_on_district_id"
  add_index "jobs", ["field_id"], :name => "index_jobs_on_field_id"
  add_index "jobs", ["job_template_id"], :name => "index_jobs_on_job_template_id"
  add_index "jobs", ["well_id"], :name => "index_jobs_on_well_id"

  create_table "messages", :force => true do |t|
    t.integer  "conversation_id"
    t.integer  "user_id"
    t.string   "text",            :limit => 2000
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "company_id"
  end

  add_index "messages", ["conversation_id"], :name => "index_messages_on_conversation_id"
  add_index "messages", ["user_id"], :name => "index_messages_on_user_id"

  create_table "mud_records", :force => true do |t|
    t.integer  "company_id"
    t.integer  "user_id"
    t.integer  "document_id"
    t.string   "type"
    t.decimal  "weight"
    t.decimal  "visc"
    t.decimal  "chlorides"
    t.decimal  "yp"
    t.decimal  "pv"
    t.decimal  "ph"
    t.decimal  "gas"
    t.decimal  "sand"
    t.decimal  "wl"
    t.decimal  "solid"
    t.decimal  "bht"
    t.decimal  "flow_t"
    t.decimal  "oil"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "mud_records", ["document_id"], :name => "index_mud_records_on_document_id"

  create_table "note_activity_reports", :force => true do |t|
    t.integer  "company_id"
    t.integer  "job_id"
    t.string   "past"
    t.string   "present"
    t.string   "future"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "job_note_id"
  end

  add_index "note_activity_reports", ["job_id"], :name => "index_note_activity_reports_on_job_id"
  add_index "note_activity_reports", ["job_note_id"], :name => "index_note_activity_reports_on_job_note_id"

  create_table "part_memberships", :force => true do |t|
    t.integer  "primary_tool_id"
    t.string   "material_number", :limit => 30
    t.integer  "job_id"
    t.integer  "part_id"
    t.boolean  "template",                      :default => true
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
    t.integer  "company_id"
    t.boolean  "track_usage"
    t.float    "usage"
    t.boolean  "optional",                      :default => false
    t.string   "name"
    t.string   "serial_number"
    t.boolean  "received",                      :default => false
    t.datetime "received_at"
    t.integer  "received_by"
    t.integer  "part_type"
  end

  add_index "part_memberships", ["job_id"], :name => "index_part_memberships_on_job_id"
  add_index "part_memberships", ["material_number"], :name => "index_part_memberships_on_material_number"
  add_index "part_memberships", ["primary_tool_id"], :name => "index_part_memberships_on_primary_tool_id"

  create_table "part_redresses", :force => true do |t|
    t.integer  "company_id"
    t.integer  "part_id"
    t.integer  "job_id"
    t.string   "notes"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.datetime "received_at"
    t.datetime "finished_redress_at"
    t.integer  "received_by_id"
    t.integer  "finished_redress_by_id"
    t.string   "received_by_name"
    t.string   "finished_redress_by_name"
    t.boolean  "no_redress",               :default => false
  end

  create_table "parts", :force => true do |t|
    t.string   "name"
    t.string   "part_number"
    t.boolean  "template",                             :default => false
    t.integer  "master_part_id"
    t.integer  "status"
    t.integer  "current_job_id"
    t.integer  "primary_tool_id"
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
    t.integer  "district_id"
    t.boolean  "active",                               :default => true
    t.string   "material_number",        :limit => 30
    t.string   "serial_number",          :limit => 30
    t.string   "district_serial_number", :limit => 30
    t.integer  "total_count",                          :default => 0
    t.integer  "on_hand_count",                        :default => 0
    t.string   "location"
    t.integer  "total_uses",                           :default => 0
    t.integer  "company_id"
    t.integer  "warehouse_id"
  end

  add_index "parts", ["company_id"], :name => "index_parts_on_company_id"
  add_index "parts", ["district_id"], :name => "index_parts_on_district_id"
  add_index "parts", ["district_serial_number"], :name => "index_parts_on_district_serial_number"
  add_index "parts", ["material_number"], :name => "index_parts_on_material_number"
  add_index "parts", ["part_number"], :name => "index_parts_on_part_number"
  add_index "parts", ["serial_number"], :name => "index_parts_on_serial_number"

  create_table "post_job_report_documents", :force => true do |t|
    t.integer  "document_id"
    t.integer  "job_template_id"
    t.integer  "ordering"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "company_id"
  end

  add_index "post_job_report_documents", ["document_id"], :name => "index_post_job_report_documents_on_document_id"
  add_index "post_job_report_documents", ["job_template_id"], :name => "index_post_job_report_documents_on_job_template_id"

  create_table "primary_tools", :force => true do |t|
    t.integer  "tool_id"
    t.integer  "job_template_id"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.integer  "company_id"
    t.integer  "job_id"
    t.string   "comments"
    t.boolean  "template",        :default => true
    t.string   "serial_number"
    t.boolean  "received",        :default => false
    t.boolean  "simple_tracking", :default => false
  end

  add_index "primary_tools", ["job_template_id"], :name => "index_primary_tools_on_job_template_id"
  add_index "primary_tools", ["tool_id"], :name => "index_primary_tools_on_tool_id"

  create_table "product_lines", :force => true do |t|
    t.string   "name"
    t.integer  "company_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "segment_id"
  end

  add_index "product_lines", ["company_id"], :name => "index_product_lines_on_company_id"

  create_table "rig_memberships", :force => true do |t|
    t.integer  "company_id"
    t.integer  "crew_id"
    t.integer  "user_id"
    t.string   "user_name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "rig_id"
  end

  add_index "rig_memberships", ["rig_id"], :name => "index_rig_memberships_on_rig_id"
  add_index "rig_memberships", ["user_id", "rig_id"], :name => "index_rig_memberships_on_user_id_and_rig_id", :unique => true
  add_index "rig_memberships", ["user_id"], :name => "index_crew_memberships_on_user_id"

  create_table "rigs", :force => true do |t|
    t.integer  "company_id"
    t.string   "name"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.integer  "rig_memberships_count", :default => 0
  end

  create_table "secondary_tools", :force => true do |t|
    t.integer  "tool_id"
    t.integer  "job_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "company_id"
    t.string   "serial_number"
    t.boolean  "received",      :default => false
  end

  add_index "secondary_tools", ["job_id"], :name => "index_secondary_tools_on_job_id"
  add_index "secondary_tools", ["tool_id"], :name => "index_secondary_tools_on_tool_id"

  create_table "segments", :force => true do |t|
    t.string   "name"
    t.integer  "company_id"
    t.integer  "division_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "segments", ["company_id"], :name => "index_segments_on_company_id"
  add_index "segments", ["division_id"], :name => "index_segments_on_division_id"

  create_table "states", :force => true do |t|
    t.string   "iso"
    t.string   "name"
    t.integer  "country_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "states", ["country_id"], :name => "index_states_on_country_id"

  create_table "survey_points", :force => true do |t|
    t.integer  "company_id"
    t.integer  "survey_id"
    t.decimal  "measured_depth"
    t.decimal  "inclination"
    t.decimal  "azimuth"
    t.boolean  "tie_on"
    t.decimal  "true_vertical_depth"
    t.decimal  "north_south"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.decimal  "east_west"
    t.string   "comment"
    t.decimal  "vertical_section"
    t.integer  "user_id"
    t.string   "user_name"
    t.decimal  "course_length"
    t.decimal  "dog_leg_severity"
    t.decimal  "closure_distance"
    t.decimal  "closure_angle"
  end

  add_index "survey_points", ["survey_id"], :name => "index_survey_points_on_survey_id"

  create_table "surveys", :force => true do |t|
    t.integer  "company_id"
    t.integer  "document_id"
    t.integer  "job_id"
    t.integer  "user_id"
    t.boolean  "plan"
    t.string   "name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "surveys", ["document_id"], :name => "index_surveys_on_document_id"
  add_index "surveys", ["job_id"], :name => "index_surveys_on_job_id"

  create_table "tools", :force => true do |t|
    t.string   "name"
    t.integer  "company_id"
    t.integer  "division_id"
    t.integer  "product_line_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "description"
  end

  add_index "tools", ["company_id"], :name => "index_tools_on_company_id"
  add_index "tools", ["division_id"], :name => "index_tools_on_division_id"
  add_index "tools", ["product_line_id"], :name => "index_tools_on_product_line_id"

  create_table "user_logins", :force => true do |t|
    t.integer  "company_id"
    t.integer  "user_id"
    t.string   "ip_address", :limit => 200
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "user_logins", ["company_id"], :name => "index_user_logins_on_company_id"
  add_index "user_logins", ["user_id"], :name => "index_user_logins_on_user_id"

  create_table "user_roles", :force => true do |t|
    t.string   "title"
    t.integer  "company_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "role_id"
  end

  add_index "user_roles", ["company_id"], :name => "index_user_roles_on_company_id"

  create_table "user_units", :force => true do |t|
    t.integer  "user_id"
    t.integer  "length_outer"
    t.integer  "length_inner"
    t.integer  "temperature"
    t.integer  "pressure"
    t.integer  "rate"
    t.integer  "volume"
    t.integer  "area"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "weight"
    t.integer  "weight_casing"
    t.integer  "weight_gradient"
    t.integer  "company_id"
    t.integer  "viscosity"
  end

  add_index "user_units", ["user_id"], :name => "index_user_units_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.boolean  "admin",                                  :default => false
    t.integer  "company_id"
    t.integer  "district_id"
    t.string   "location"
    t.string   "phone_number"
    t.datetime "created_at",                                                :null => false
    t.datetime "updated_at",                                                :null => false
    t.string   "password_digest"
    t.boolean  "elephant_admin",                         :default => false
    t.string   "remember_token"
    t.boolean  "create_password",                        :default => false
    t.integer  "role_id"
    t.integer  "product_line_id"
    t.string   "time_zone"
    t.string   "language"
    t.boolean  "send_daily_activity",                    :default => true
    t.boolean  "accepted_tou",                           :default => false
    t.string   "unverified_network"
    t.string   "network_access_code"
    t.string   "verified_networks",      :limit => 2000
    t.integer  "division_id"
    t.integer  "segment_id"
    t.integer  "invalid_login_attempts",                 :default => 0
  end

  add_index "users", ["company_id"], :name => "index_users_on_company_id"
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

  create_table "warehouse_memberships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "company_id"
    t.integer  "warehouse_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "warehouse_memberships", ["user_id", "warehouse_id"], :name => "index_warehouse_memberships_on_user_id_and_warehouse_id", :unique => true
  add_index "warehouse_memberships", ["user_id"], :name => "index_warehouse_memberships_on_user_id"
  add_index "warehouse_memberships", ["warehouse_id"], :name => "index_warehouse_memberships_on_warehouse_id"

  create_table "warehouses", :force => true do |t|
    t.integer  "company_id"
    t.integer  "district_id"
    t.string   "name"
    t.string   "location"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "warehouses", ["company_id"], :name => "index_warehouses_on_company_id"
  add_index "warehouses", ["district_id"], :name => "index_warehouses_on_district_id"

  create_table "wells", :force => true do |t|
    t.string   "name"
    t.integer  "company_id"
    t.integer  "field_id"
    t.datetime "created_at",                                                                 :null => false
    t.datetime "updated_at",                                                                 :null => false
    t.float    "measured_depth"
    t.float    "true_vertical_depth"
    t.float    "water_depth"
    t.boolean  "offshore",                                                :default => false
    t.float    "bottom_hole_temperature"
    t.float    "bottom_hole_formation_pressure"
    t.float    "frac_pressure"
    t.float    "max_deviation"
    t.float    "bottom_deviation"
    t.string   "rig_name"
    t.integer  "measured_depth_value_type",                               :default => 1
    t.integer  "true_vertical_depth_value_type",                          :default => 1
    t.integer  "water_depth_value_type",                                  :default => 1
    t.integer  "bottom_hole_temperature_value_type",                      :default => 1
    t.integer  "bottom_hole_formation_pressure_value_type",               :default => 1
    t.integer  "frac_pressure_value_type",                                :default => 1
    t.string   "location",                                  :limit => 50
    t.string   "formation"
    t.string   "bottom_hole_location",                      :limit => 50
    t.integer  "rig_id"
    t.integer  "datum",                                                   :default => 1
  end

  add_index "wells", ["company_id"], :name => "index_wells_on_company_id"
  add_index "wells", ["field_id"], :name => "index_wells_on_field_id"

end
