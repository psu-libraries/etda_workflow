class ChangeCandidateNumberToStringInSubmission < ActiveRecord::Migration[6.1]
  def self.up
    change_table :submissions do |t|
      t.change :candidate_number, :string
    end
  end

  def self.down
    change_table :submissions do |t|
      t.change :candidate_number, :integer
    end
  end
end
