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

ActiveRecord::Schema.define(version: 20171212004556) do

  create_table "admins", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "access_id", default: "", null: false
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "psu_email_address"
    t.string "address_1"
    t.string "phone_number"
    t.string "psu_idn"
    t.boolean "administrator"
    t.boolean "site_administrator"
    t.index ["access_id"], name: "index_admins_on_access_id", unique: true
  end

  create_table "authors", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "access_id", default: "", null: false
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "middle_name"
    t.string "alternate_email_address"
    t.boolean "is_alternate_email_public"
    t.string "psu_email_address"
    t.string "address_1"
    t.string "address_2"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "country"
    t.string "phone_number"
    t.string "psu_idn"
    t.integer "legacy_id"
    t.boolean "confidential_hold"
    t.datetime "confidential_hold_set_at"
    t.index ["access_id"], name: "index_authors_on_access_id", unique: true
    t.index ["legacy_id"], name: "index_authors_on_legacy_id"
  end

  create_table "committee_members", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "submission_id"
    t.bigint "committee_role_id"
    t.string "name"
    t.string "email"
    t.integer "legacy_id"
    t.boolean "is_required"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["committee_role_id"], name: "committee_members_committee_role_id_fk"
    t.index ["submission_id"], name: "committee_members_submission_id_fk"
  end

  create_table "committee_roles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "degree_type_id", null: false
    t.string "name", null: false
    t.integer "num_required", default: 0, null: false
    t.boolean "is_active", default: true, null: false
    t.index ["degree_type_id"], name: "committee_roles_degree_type_id_fk"
  end

  create_table "degree_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.index ["name"], name: "index_degree_types_on_name", unique: true
    t.index ["slug"], name: "index_degree_types_on_slug", unique: true
  end

  create_table "degrees", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.string "description"
    t.boolean "is_active"
    t.integer "degree_type_id", null: false
    t.integer "legacy_id"
    t.integer "legacy_old_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["degree_type_id"], name: "index_degrees_on_degree_type_id"
    t.index ["legacy_id"], name: "index_degrees_on_legacy_id"
  end

  create_table "final_submission_files", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "submission_id"
    t.text "asset"
    t.integer "legacy_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["legacy_id"], name: "index_final_submission_files_on_legacy_id"
    t.index ["submission_id"], name: "final_submission_files_submission_id_fk"
  end

  create_table "format_review_files", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "submission_id"
    t.text "asset"
    t.integer "legacy_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["legacy_id"], name: "index_format_review_files_on_legacy_id"
    t.index ["submission_id"], name: "format_review_files_submission_id_fk"
  end

  create_table "invention_disclosures", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "submission_id"
    t.string "id_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["submission_id"], name: "invention_disclosures_submission_id_fk"
  end

  create_table "keywords", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "submission_id"
    t.text "word"
    t.integer "legacy_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["legacy_id"], name: "index_keywords_on_legacy_id"
    t.index ["submission_id"], name: "keywords_submission_id_fk"
  end

  create_table "programs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.string "description"
    t.boolean "is_active"
    t.integer "legacy_id"
    t.integer "legacy_old_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["legacy_id"], name: "index_programs_on_legacy_id"
  end

  create_table "submissions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "author_id"
    t.bigint "program_id"
    t.bigint "degree_id"
    t.string "semester"
    t.integer "year"
    t.string "status"
    t.string "title", limit: 400
    t.text "format_review_notes"
    t.text "final_submission_notes"
    t.datetime "defended_at"
    t.text "abstract"
    t.string "access_level"
    t.boolean "has_agreed_to_terms"
    t.datetime "committee_provided_at"
    t.datetime "format_review_files_uploaded_at"
    t.datetime "format_review_rejected_at"
    t.datetime "format_review_approved_at"
    t.datetime "final_submission_files_uploaded_at"
    t.datetime "final_submission_rejected_at"
    t.datetime "final_submission_approved_at"
    t.datetime "released_for_publication_at"
    t.datetime "released_metadata_at"
    t.integer "legacy_id"
    t.integer "format_review_legacy_id"
    t.integer "format_review_legacy_old_id"
    t.integer "final_submission_legacy_id"
    t.integer "final_submission_legacy_old_id"
    t.string "admin_notes"
    t.boolean "is_printed"
    t.boolean "allow_all_caps_in_title"
    t.string "public_id"
    t.datetime "format_review_files_first_uploaded_at"
    t.datetime "final_submission_files_first_uploaded_at"
    t.string "lion_path_degree_code"
    t.text "restricted_notes"
    t.datetime "confidential_hold_embargoed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "submissions_author_id_fk"
    t.index ["degree_id"], name: "submissions_degree_id_fk"
    t.index ["final_submission_legacy_id"], name: "index_submissions_on_final_submission_legacy_id"
    t.index ["final_submission_legacy_old_id"], name: "index_submissions_on_final_submission_legacy_old_id"
    t.index ["format_review_legacy_id"], name: "index_submissions_on_format_review_legacy_id"
    t.index ["format_review_legacy_old_id"], name: "index_submissions_on_format_review_legacy_old_id"
    t.index ["legacy_id"], name: "index_submissions_on_legacy_id"
    t.index ["program_id"], name: "submissions_program_id_fk"
    t.index ["public_id"], name: "index_submissions_on_public_id", unique: true
  end

  add_foreign_key "committee_members", "committee_roles", name: "committee_members_committee_role_id_fk"
  add_foreign_key "committee_members", "submissions", name: "committee_members_submission_id_fk"
  add_foreign_key "committee_roles", "degree_types", name: "committee_roles_degree_type_id_fk"
  add_foreign_key "final_submission_files", "submissions", name: "final_submission_files_submission_id_fk"
  add_foreign_key "format_review_files", "submissions", name: "format_review_files_submission_id_fk"
  add_foreign_key "invention_disclosures", "submissions", name: "invention_disclosures_submission_id_fk"
  add_foreign_key "keywords", "submissions", name: "keywords_submission_id_fk"
  add_foreign_key "submissions", "authors", name: "submissions_author_id_fk"
  add_foreign_key "submissions", "degrees", name: "submissions_degree_id_fk"
  add_foreign_key "submissions", "programs", name: "submissions_program_id_fk"
end
