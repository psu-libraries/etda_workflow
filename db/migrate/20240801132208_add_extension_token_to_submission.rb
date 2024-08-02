class AddExtensionTokenToSubmission < ActiveRecord::Migration[6.1]
  def change
    add_column :submissions, :extension_token, :string
  end
end
