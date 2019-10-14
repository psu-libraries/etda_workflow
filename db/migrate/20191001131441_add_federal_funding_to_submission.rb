class AddFederalFundingToSubmission < ActiveRecord::Migration[5.1]
  def change
    add_column :submissions, :federal_funding, :boolean
  end
end
