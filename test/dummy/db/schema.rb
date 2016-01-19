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

ActiveRecord::Schema.define(version: 20160119053447) do

  create_table "authors", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_group_id"
  end

  create_table "books", force: true do |t|
    t.integer  "author_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "edgarj_model_permissions", force: true do |t|
    t.integer  "user_group_id"
    t.string   "name"
    t.integer  "flags"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "model"
  end

  add_index "edgarj_model_permissions", ["model"], name: "index_edgarj_model_permissions_on_model", using: :btree

  create_table "edgarj_page_infos", force: true do |t|
    t.integer  "sssn_id"
    t.string   "view"
    t.string   "order_by"
    t.string   "dir"
    t.integer  "page"
    t.integer  "lines"
    t.text     "record_data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "edgarj_sssns", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "edgarj_sssns", ["session_id"], name: "index_edgarj_sssns_on_session_id", using: :btree
  add_index "edgarj_sssns", ["updated_at"], name: "index_edgarj_sssns_on_updated_at", using: :btree

  create_table "edgarj_user_group_users", force: true do |t|
    t.integer  "user_group_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "edgarj_user_groups", force: true do |t|
    t.integer  "kind"
    t.string   "name"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "edgarj_user_groups", ["kind"], name: "index_edgarj_user_groups_on_kind", using: :btree
  add_index "edgarj_user_groups", ["lft"], name: "index_edgarj_user_groups_on_lft", using: :btree
  add_index "edgarj_user_groups", ["parent_id"], name: "index_edgarj_user_groups_on_parent_id", using: :btree
  add_index "edgarj_user_groups", ["rgt"], name: "index_edgarj_user_groups_on_rgt", using: :btree

  create_table "users", force: true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
