class AddAcademicProgramAndDegreeCheckoutStatusToSubmission < ActiveRecord::Migration[6.0]
  def change
    add_column :submissions, :academic_program, :string
    add_column :submissions, :degree_checkout_status, :string
  end
end
