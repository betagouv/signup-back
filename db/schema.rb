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

ActiveRecord::Schema.define(version: 20190329164933) do

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
    t.json "scopes", default: {}
    t.json "contacts", array: true
    t.string "siret"
    t.json "demarche"
    t.json "donnees", default: {"destinaires"=>{}}
    t.string "state"
    t.boolean "validation_de_convention"
    t.string "fournisseur_de_donnees"
    t.string "type"
    t.string "description_service"
    t.string "fondement_juridique"
    t.boolean "scope_dgfip_RFR"
    t.boolean "scope_dgfip_adresse_fiscale_taxation"
    t.integer "nombre_demandes_annuelle"
    t.integer "pic_demandes_par_seconde"
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
    t.string "autorite_homologation_nom"
    t.string "autorite_homologation_fonction"
    t.date "date_homologation"
    t.date "date_fin_homologation"
    t.string "delegue_protection_donnees"
    t.string "certificat_pub_production"
    t.string "autorite_certification"
    t.string "ips_de_production"
    t.boolean "mise_en_production"
    t.boolean "recette_fonctionnelle"
    t.boolean "demarche_cnil"
    t.boolean "administration"
    t.boolean "france_connect"
    t.boolean "autorisation_legale"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "url_fondement_juridique"
    t.string "token_id"
    t.string "nom_raison_sociale"
    t.integer "linked_franceconnect_enrollment_id"
    t.bigint "user_id"
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
