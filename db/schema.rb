# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_08_26_183515) do
  create_table "admin_feedback_files", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "submission_id"
    t.text "asset"
    t.string "feedback_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admins", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "access_id", default: "", null: false
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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

  create_table "approval_configurations", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "degree_type_id"
    t.date "approval_deadline_on"
    t.integer "configuration_threshold"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "email_admins"
    t.boolean "email_authors"
    t.boolean "use_percentage"
    t.boolean "head_of_program_is_approving"
    t.index ["degree_type_id"], name: "degree_type_id_fk"
  end

  create_table "approvers", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "access_id", default: "", null: false
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["access_id"], name: "index_approvers_on_access_id", unique: true
  end

  create_table "authors", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "access_id", default: "", null: false
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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
    t.datetime "confidential_hold_set_at", precision: nil
    t.datetime "admin_edited_at", precision: nil
    t.index ["access_id"], name: "index_authors_on_access_id", unique: true
    t.index ["legacy_id"], name: "index_authors_on_legacy_id"
  end

  create_table "committee_member_tokens", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "authentication_token"
    t.bigint "committee_member_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.date "token_created_on"
    t.index ["committee_member_id"], name: "index_committee_member_tokens_on_committee_member_id"
  end

  create_table "committee_members", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "submission_id"
    t.bigint "committee_role_id"
    t.string "name"
    t.string "email"
    t.integer "legacy_id"
    t.boolean "is_required"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "access_id"
    t.datetime "approval_started_at", precision: nil
    t.datetime "approved_at", precision: nil
    t.datetime "rejected_at", precision: nil
    t.datetime "reset_at", precision: nil
    t.datetime "last_notified_at", precision: nil
    t.string "last_notified_type"
    t.text "notes"
    t.string "status", default: ""
    t.datetime "last_reminder_at", precision: nil
    t.boolean "is_voting", default: false
    t.boolean "federal_funding_used"
    t.bigint "approver_id"
    t.datetime "lionpath_updated_at", precision: nil
    t.string "external_to_psu_id"
    t.bigint "faculty_member_id"
    t.index ["approver_id"], name: "index_committee_members_on_approver_id"
    t.index ["committee_role_id"], name: "committee_members_committee_role_id_fk"
    t.index ["faculty_member_id"], name: "committee_members_faculty_member_id_fk"
    t.index ["submission_id"], name: "committee_members_submission_id_fk"
  end

  create_table "committee_roles", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "degree_type_id", null: false
    t.string "name", null: false
    t.integer "num_required", default: 0, null: false
    t.boolean "is_active", default: true, null: false
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "lionpath_updated_at", precision: nil
    t.boolean "is_program_head"
    t.index ["degree_type_id"], name: "committee_roles_degree_type_id_fk"
  end

  create_table "confidential_hold_histories", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "author_id", null: false
    t.datetime "set_at", precision: nil
    t.datetime "removed_at", precision: nil
    t.string "set_by"
    t.string "removed_by"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["author_id"], name: "index_confidential_hold_histories_on_author_id"
  end

  create_table "degree_types", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.index ["name"], name: "index_degree_types_on_name", unique: true
    t.index ["slug"], name: "index_degree_types_on_slug", unique: true
  end

  create_table "degrees", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.boolean "is_active"
    t.integer "degree_type_id", null: false
    t.integer "legacy_id"
    t.integer "legacy_old_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["degree_type_id"], name: "index_degrees_on_degree_type_id"
    t.index ["legacy_id"], name: "index_degrees_on_legacy_id"
    t.index ["name"], name: "index_degrees_on_name", unique: true
  end

  create_table "faculty_members", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "middle_name"
    t.string "last_name", null: false
    t.string "department"
    t.string "webaccess_id", null: false
    t.string "college"
    t.index ["webaccess_id"], name: "index_faculty_members_on_webaccess_id", unique: true
  end

  create_table "federal_funding_details", charset: "utf8mb4", force: :cascade do |t|
    t.boolean "training_support_funding"
    t.boolean "other_funding"
    t.boolean "training_support_acknowledged"
    t.boolean "other_funding_acknowledged"
    t.bigint "submission_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["submission_id"], name: "index_federal_funding_details_on_submission_id"
  end

  create_table "final_submission_files", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "submission_id"
    t.text "asset", size: :medium
    t.integer "legacy_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["legacy_id"], name: "index_final_submission_files_on_legacy_id"
    t.index ["submission_id"], name: "final_submission_files_submission_id_fk"
  end

  create_table "format_review_files", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "submission_id"
    t.text "asset", size: :medium
    t.integer "legacy_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["legacy_id"], name: "index_format_review_files_on_legacy_id"
    t.index ["submission_id"], name: "format_review_files_submission_id_fk"
  end

  create_table "invention_disclosures", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "submission_id"
    t.string "id_number"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["submission_id"], name: "invention_disclosures_submission_id_fk"
  end

  create_table "keywords", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "submission_id"
    t.text "word", size: :medium
    t.integer "legacy_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["legacy_id"], name: "index_keywords_on_legacy_id"
    t.index ["submission_id"], name: "keywords_submission_id_fk"
  end

  create_table "programs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.boolean "is_active"
    t.integer "legacy_id"
    t.integer "legacy_old_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "code"
    t.datetime "lionpath_updated_at", precision: nil
    t.index ["legacy_id"], name: "index_programs_on_legacy_id"
    t.index ["name", "code"], name: "index_programs_on_name_and_code", unique: true
  end

  create_table "submissions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "author_id"
    t.bigint "program_id"
    t.bigint "degree_id"
    t.string "semester"
    t.integer "year"
    t.string "status"
    t.string "title", limit: 400
    t.text "format_review_notes", size: :medium
    t.text "final_submission_notes", size: :medium
    t.datetime "defended_at", precision: nil
    t.text "abstract", size: :medium
    t.string "access_level"
    t.boolean "has_agreed_to_terms"
    t.datetime "committee_provided_at", precision: nil
    t.datetime "format_review_files_uploaded_at", precision: nil
    t.datetime "format_review_rejected_at", precision: nil
    t.datetime "format_review_approved_at", precision: nil
    t.datetime "final_submission_files_uploaded_at", precision: nil
    t.datetime "final_submission_rejected_at", precision: nil
    t.datetime "final_submission_approved_at", precision: nil
    t.datetime "released_for_publication_at", precision: nil
    t.datetime "released_metadata_at", precision: nil
    t.integer "legacy_id"
    t.integer "format_review_legacy_id"
    t.integer "format_review_legacy_old_id"
    t.integer "final_submission_legacy_id"
    t.integer "final_submission_legacy_old_id"
    t.string "admin_notes"
    t.boolean "is_printed"
    t.boolean "allow_all_caps_in_title"
    t.string "public_id"
    t.datetime "format_review_files_first_uploaded_at", precision: nil
    t.datetime "final_submission_files_first_uploaded_at", precision: nil
    t.string "lion_path_degree_code"
    t.text "restricted_notes", size: :medium
    t.datetime "publication_release_terms_agreed_to_at", precision: nil
    t.boolean "has_agreed_to_publication_release"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "committee_review_accepted_at", precision: nil
    t.datetime "committee_review_rejected_at", precision: nil
    t.datetime "head_of_program_review_accepted_at", precision: nil
    t.datetime "head_of_program_review_rejected_at", precision: nil
    t.boolean "federal_funding"
    t.datetime "placed_on_hold_at", precision: nil
    t.datetime "removed_hold_at", precision: nil
    t.string "campus"
    t.datetime "lionpath_updated_at", precision: nil
    t.datetime "proquest_agreement_at", precision: nil
    t.boolean "proquest_agreement"
    t.integer "lionpath_year"
    t.string "lionpath_semester"
    t.string "academic_program"
    t.string "degree_checkout_status"
    t.datetime "author_release_warning_sent_at", precision: nil
    t.datetime "acknowledgment_page_submitted_at", precision: nil
    t.string "candidate_number"
    t.string "extension_token"
    t.datetime "last_lionpath_export_at", precision: nil
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

  add_foreign_key "approval_configurations", "degree_types", name: "degree_type_id_fk"
  add_foreign_key "committee_member_tokens", "committee_members", name: "committee_member_tokens_committee_member_id_fk"
  add_foreign_key "committee_members", "approvers", name: "committee_members_approver_id_fk"
  add_foreign_key "committee_members", "committee_roles", name: "committee_members_committee_role_id_fk"
  add_foreign_key "committee_members", "faculty_members", name: "committee_members_faculty_member_id_fk", on_delete: :nullify
  add_foreign_key "committee_members", "submissions", name: "committee_members_submission_id_fk"
  add_foreign_key "committee_roles", "degree_types", name: "committee_roles_degree_type_id_fk"
  add_foreign_key "confidential_hold_histories", "authors", name: "confidential_hold_histories_author_id_fk"
  add_foreign_key "federal_funding_details", "submissions"
  add_foreign_key "final_submission_files", "submissions", name: "final_submission_files_submission_id_fk"
  add_foreign_key "format_review_files", "submissions", name: "format_review_files_submission_id_fk"
  add_foreign_key "invention_disclosures", "submissions", name: "invention_disclosures_submission_id_fk"
  add_foreign_key "keywords", "submissions", name: "keywords_submission_id_fk"
  add_foreign_key "submissions", "authors", name: "submissions_author_id_fk"
  add_foreign_key "submissions", "degrees", name: "submissions_degree_id_fk"
  add_foreign_key "submissions", "programs", name: "submissions_program_id_fk"
end
