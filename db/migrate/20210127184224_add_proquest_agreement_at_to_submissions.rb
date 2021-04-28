class AddProquestAgreementAtToSubmissions < ActiveRecord::Migration[6.0]
  def self.up
    add_column :submissions, :proquest_agreement_at, :datetime
    add_column :submissions, :proquest_agreement, :boolean
  end

  def self.down
    remove_column :submissions, :proquest_agreement_at
    remove_column :submissions, :proquest_agreement
  end
end
