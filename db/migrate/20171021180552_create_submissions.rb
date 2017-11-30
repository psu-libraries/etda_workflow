class CreateSubmissions < ActiveRecord::Migration[5.1]

  def change
    create_table :submissions do |t|
      t.bigint :author_id
      t.bigint :program_id
      t.bigint :degree_id
      t.string :semester
      t.integer :year
      t.string :status
      t.string :title, limit: 400
      t.text :format_review_notes
      t.text :final_submission_notes
      t.datetime :defended_at
      t.text :abstract
      t.string :access_level
      t.boolean :has_agreed_to_terms
      t.datetime :committee_provided_at
      t.datetime :format_review_files_uploaded_at
      t.datetime :format_review_rejected_at
      t.datetime :format_review_approved_at
      t.datetime :final_submission_files_uploaded_at
      t.datetime :final_submission_rejected_at
      t.datetime :final_submission_approved_at
      t.datetime :released_for_publication_at
      t.datetime :released_metadata_at
      t.integer :legacy_id
      t.integer :format_review_legacy_id
      t.integer :format_review_legacy_old_id
      t.integer :final_submission_legacy_id
      t.integer :final_submission_legacy_old_id
      t.string :admin_notes
      t.boolean :is_printed
      t.boolean :allow_all_caps_in_title
      t.string :public_id
      t.datetime :format_review_files_first_uploaded_at
      t.datetime :final_submission_files_first_uploaded_at
      t.string :lion_path_degree_code
      t.text :restricted_notes
      t.datetime :confidential_hold_embargoed_at
      t.timestamps
    end

    add_index :submissions, :legacy_id
    add_index :submissions, :final_submission_legacy_id
    add_index :submissions, :final_submission_legacy_old_id
    add_index :submissions, :format_review_legacy_id
    add_index :submissions, :format_review_legacy_old_id
    add_index :submissions, :public_id, unique: true
    add_foreign_key :submissions, :authors, name: :submissions_author_id_fk, dependent: :delete
    add_foreign_key :submissions, :degrees, name: :submissions_degree_id_fk, dependent: :delete
    add_foreign_key :submissions, :programs, name: :submissions_program_id_fk, dependent: :delete
  end
end
