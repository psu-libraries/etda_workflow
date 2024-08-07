require 'model_spec_helper'

RSpec.describe Lionpath::LionpathExportPayload do
  let(:status_behavior) { double('StatusBehavior') }
  let(:submission) { double('Submission', 
                            author: double('Author', psu_idn: '123456789'), 
                            candidate_number: 'C123456',
                            title: 'My Thesis Title',
                            released_metadata_at: Time.new(2024, 8, 7),
                            released_for_publication_at: Time.new(2024, 12, 25),
                            access_level: 'open_access',
                            status_behavior: status_behavior,
                            final_submission_files_uploaded_at: Time.new(2024, 8, 7),
                            federal_funding: true) }

  subject { described_class.new(submission) }

  describe '#json_payload' do
    before do
      allow(status_behavior).to receive(:beyond_collecting_format_review_files?).and_return(true)
      allow(status_behavior).to receive(:beyond_waiting_for_committee_review_rejected?).and_return(false)
    end

    it 'returns JSON formatted object' do
      expected_payload = {
        "PE_SR199_ETD_REQ" => {
          "emplid" => "123456789",
          "candNbr" => "C123456",
          "thesisTitle" => "My Thesis Title",
          "thesisStatus" => "SUBMITTED",
          "embargoType" => "OPEN",
          "embargoStartDt" => "20240807",
          "embargoEndDt" => "20241225",
          "exPymtFlg" => "Y"
        }
      }.to_json

      expect(subject.json_payload).to eq(expected_payload)
    end

    context 'when thesis is beyond_collecting_format_review_files but not beyond_waiting_for_committee_review_rejected' do
      it 'sets thesisStatus to SUBMITTED' do
        payload = JSON.parse(subject.json_payload)
        expect(payload["PE_SR199_ETD_REQ"]["thesisStatus"]).to eq("SUBMITTED")
      end

      it 'does not set libDepFlg"' do
        payload = JSON.parse(subject.json_payload)
        expect(payload["PE_SR199_ETD_REQ"]["libDepFlg"]).to be_nil
      end
    end

    context 'when thesis is beyond_collecting_format_review_files and beyond_waiting_for_committee_review_rejected' do
      before do
        allow(status_behavior).to receive(:beyond_collecting_format_review_files?).and_return(true)
        allow(status_behavior).to receive(:beyond_waiting_for_committee_review_rejected?).and_return(true)
      end

      it 'sets thesisStatus to APPROVED' do
        payload = JSON.parse(subject.json_payload)
        expect(payload["PE_SR199_ETD_REQ"]["thesisStatus"]).to eq("APPROVED")
      end

      it 'sets candAdvFlg to Y' do
        payload = JSON.parse(subject.json_payload)
        expect(payload["PE_SR199_ETD_REQ"]["candAdvFlg"]).to eq("Y")
      end

      it 'sets grdtnFlg to Y' do
        payload = JSON.parse(subject.json_payload)
        expect(payload["PE_SR199_ETD_REQ"]["grdtnFlg"]).to eq("Y")
      end

      context 'when federal funding is true' do
        it 'sets libDepFlg to "Y"' do
          payload = JSON.parse(subject.json_payload)
          expect(payload["PE_SR199_ETD_REQ"]["libDepFlg"]).to eq("Y")
        end
      end

      context 'when federal funding is false' do
        it 'sets libDepFlg to "N"' do
          allow(submission).to receive(:federal_funding).and_return(false)
          payload = JSON.parse(subject.json_payload)
          expect(payload["PE_SR199_ETD_REQ"]["libDepFlg"]).to eq("N")
        end
      end

      context 'when federal funding is nil' do
        it 'does not set libDepFlg' do
          allow(submission).to receive(:federal_funding).and_return(nil)
          payload = JSON.parse(subject.json_payload)
          expect(payload["PE_SR199_ETD_REQ"]["libDepFlg"]).to be_nil
        end
      end
    end

    context 'when access_level is open_access' do
      it 'sets embargoType to OPEN' do
        payload = JSON.parse(subject.json_payload)
        expect(payload["PE_SR199_ETD_REQ"]["embargoType"]).to eq("OPEN")
      end
    end

    context 'when access_level is restricted_to_institution' do
      before do
        allow(submission).to receive(:access_level).and_return('restricted_to_institution')
      end

      it 'sets embargoType to RPSU' do
        payload = JSON.parse(subject.json_payload)
        expect(payload["PE_SR199_ETD_REQ"]["embargoType"]).to eq("RPSU")
      end
    end

    context 'when access_level is restricted' do
      before do
        allow(submission).to receive(:access_level).and_return('restricted')
      end

      it 'sets embargoType to RSTR' do
        payload = JSON.parse(subject.json_payload)
        expect(payload["PE_SR199_ETD_REQ"]["embargoType"]).to eq("RSTR")
      end
    end

    context 'when payment is received' do
      it 'sets exPymtFlg to Y' do
        payload = JSON.parse(subject.json_payload)
        expect(payload["PE_SR199_ETD_REQ"]["exPymtFlg"]).to eq("Y")
      end
    end

    context 'when payment is not received' do
      before do
        allow(submission).to receive(:final_submission_files_uploaded_at).and_return(nil)
      end

      it 'does not set exPymtFlg' do
        payload = JSON.parse(subject.json_payload)
        expect(payload["PE_SR199_ETD_REQ"]["exPymtFlg"]).to be_nil
      end
    end
  end
end
