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

ActiveRecord::Schema.define(version: 20180322165139) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "documents", force: :cascade do |t|
    t.string "attachment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "enrollment_id"
    t.string "type"
    t.boolean "archive", default: false
  end

  create_table "enrollments", force: :cascade do |t|
    t.string "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "fournisseur_de_service"
    t.string "description_service"
    t.string "fondement_juridique"
    t.integer "nombre_demandes_annuelle"
    t.integer "pic_demandes_par_heure"
    t.integer "nombre_demandes_mensuelles_jan"
    t.integer "nombre_demandes_mensuelles_fev"
    t.integer "nombre_demandes_mensuelles_mar"
    t.integer "nombre_demandes_mensuelles_avr"
    t.integer "nombre_demandes_mensuelles_mai"
    t.integer "nombre_demandes_mensuelles_jui"
    t.integer "nombre_demandes_mensuelles_jul"
    t.integer "nombre_demandes_mensuelles_aou"
    t.integer "nombre_demandes_mensuelles_sep"
    t.integer "nombre_demandes_mensuelles_oct"
    t.integer "nombre_demandes_mensuelles_nov"
    t.integer "nombre_demandes_mensuelles_dec"
    t.string "autorite_certification_nom"
    t.string "autorite_certification_fonction"
    t.date "date_homologation"
    t.date "date_fin_homologation"
    t.string "delegue_protection_donnees"
    t.string "certificat_pub_production"
    t.string "autorite_certification"
    t.boolean "validation_de_convention"
    t.boolean "scope_dgfip_avis_imposition"
    t.boolean "scope_cnaf_attestation_droits"
    t.boolean "scope_cnaf_quotient_familial"
  end

  create_table "messages", force: :cascade do |t|
    t.integer "enrollment_id"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "resource_providers", force: :cascade do |t|
    t.string "short_name"
    t.string "long_name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.integer "resource_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
  end

  create_table "scopes", force: :cascade do |t|
    t.string "name"
    t.string "human_name"
    t.text "description"
    t.integer "resource_provider_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
    t.string "oauth_roles", default: [], array: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
  end

end
