class AddFundingTypesToSubmissions < ActiveRecord::Migration[6.1]
  def change
    add_column :submissions, :training_support_funding, :boolean
    add_column :submissions, :other_funding, :boolean
  end
end
