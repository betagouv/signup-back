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

ActiveRecord::Schema.define(version: 2020_02_20_155526) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "documents", force: :cascade do |t|
    t.string "attachment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.boolean "archive", default: false
    t.string "attachable_type"
    t.integer "attachable_id"
  end

  create_table "enrollments", force: :cascade do |t|
    t.jsonb "scopes", default: {}
    t.jsonb "contacts", array: true
    t.string "siret"
    t.string "status"
    t.boolean "cgu_approved"
    t.string "target_api"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "linked_token_manager_id"
    t.string "nom_raison_sociale"
    t.integer "linked_franceconnect_enrollment_id"
    t.bigint "user_id"
    t.jsonb "additional_content", default: {}
    t.string "intitule"
    t.string "description"
    t.string "fondement_juridique_title"
    t.string "fondement_juridique_url"
    t.integer "data_retention_period"
    t.string "data_recipients"
    t.string "data_retention_comment"
    t.integer "organization_id"
    t.bigint "dpo_id"
    t.string "dpo_label"
    t.string "dpo_phone_number"
    t.bigint "responsable_traitement_id"
    t.string "responsable_traitement_label"
    t.string "responsable_traitement_phone_number"
    t.bigint "copied_from_enrollment_id"
    t.index ["copied_from_enrollment_id"], name: "index_enrollments_on_copied_from_enrollment_id"
    t.index ["dpo_id"], name: "index_enrollments_on_dpo_id"
    t.index ["responsable_traitement_id"], name: "index_enrollments_on_responsable_traitement_id"
    t.index ["user_id"], name: "index_enrollments_on_user_id"
  end

  create_table "events", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "user_id"
    t.bigint "enrollment_id"
    t.string "comment"
    t.jsonb "diff"
    t.index ["enrollment_id"], name: "index_events_on_enrollment_id"
    t.index ["name"], name: "index_events_on_name"
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "roles", default: [], array: true
    t.string "uid"
    t.boolean "email_verified", default: false
    t.jsonb "organizations", default: [], array: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["uid"], name: "index_users_on_uid", unique: true
  end

  add_foreign_key "enrollments", "enrollments", column: "copied_from_enrollment_id"
  add_foreign_key "enrollments", "users"
  add_foreign_key "enrollments", "users", column: "dpo_id"
  add_foreign_key "enrollments", "users", column: "responsable_traitement_id"
  add_foreign_key "events", "enrollments"
  add_foreign_key "events", "users"
end
