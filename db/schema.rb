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

ActiveRecord::Schema.define(version: 20190403122936) do

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
    t.json "contacts", array: true
    t.string "siret"
    t.jsonb "demarche"
    t.jsonb "donnees", default: {"destinaires"=>{}}
    t.string "state"
    t.boolean "validation_de_convention"
    t.string "fournisseur_de_donnees"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "token_id"
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
    t.index ["user_id"], name: "index_enrollments_on_user_id"
  end

  create_table "events", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "user_id"
    t.bigint "enrollment_id"
    t.string "comment"
    t.index ["enrollment_id"], name: "index_events_on_enrollment_id"
    t.index ["name"], name: "index_events_on_name"
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role"
    t.string "uid"
    t.boolean "email_verified", default: false
  end

  add_foreign_key "enrollments", "users"
  add_foreign_key "events", "enrollments"
  add_foreign_key "events", "users"
end
