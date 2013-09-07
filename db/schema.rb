# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130815081234) do

  create_table "admins", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
  end

  create_table "csv_inputs", :force => true do |t|
    t.string   "project_name"
    t.string   "server_name"
    t.integer  "school_id"
    t.text     "course_ids"
    t.text     "user_ids"
    t.boolean  "input_flag",   :default => false
    t.boolean  "deleted",      :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "csv_outputs", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "server_name"
    t.integer  "school_id"
    t.text     "course_ids"
    t.text     "user_ids"
    t.boolean  "output_flag",       :default => false
    t.boolean  "deleted",           :default => false
    t.string   "project_name"
    t.boolean  "input_flag",        :default => false
    t.datetime "input_time"
    t.string   "input_server_name"
  end

end
