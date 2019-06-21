require 'model_spec_helper'

RSpec.describe LionPath::LionPathError, type: :model, lionpath: true do
  subject = described_class.new({ pe_etd_comm_fault: { emplid: "99999", err_nbr: 400, err_msg: "No valid Academic Plan " } }, access_id = 'xxb13')

  context '#error_msg' do
    it 'creates a error message' do
      expect(subject.error_msg).to eq("Lion Path Error: 400 -- No valid Academic Plan  for Access Id: #{access_id}")
    end
  end

  context '#log_err' do
    it 'logs the error message' do
      expect(Rails.logger).to receive(:info).with(subject.error_msg)
      subject.log_error
    end
  end
end
