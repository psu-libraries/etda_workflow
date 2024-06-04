class AcknowledgmentSignatures
  include ActiveModel::Model

  # attr_accessor :sig_1, :sig_2, :sig_3, :sig_4, :sig_5, :sig_6, :sig_7
  validates :sig_1, :sig_2, :sig_3, :sig_4, :sig_5, :sig_6, :sig_7, presence: true

  # def deliver
  #   if valid?
  #     # deliver email
  #   end
  # end
end
