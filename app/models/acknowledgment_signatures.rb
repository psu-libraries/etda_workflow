class AcknowledgmentSignatures
  include ActiveModel::Model

  attr_accessor :sig_1, :sig_2, :sig_3, :sig_4, :sig_5, :sig_6, :sig_7, :sig_8

  validates :sig_1, :sig_2, :sig_3, :sig_4, :sig_5, :sig_6, :sig_7, :sig_8, presence: true
end
