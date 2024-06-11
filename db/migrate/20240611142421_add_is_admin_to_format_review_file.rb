class AddIsAdminToFormatReviewFile < ActiveRecord::Migration[6.1]
  def change
    add_column :format_review_files, :is_admin, :boolean
  end
end
