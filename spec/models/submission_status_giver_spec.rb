# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe SubmissionStatusGiver, type: :model do
  let(:submission) { FactoryBot.create :submission }

  describe '#can_respond_to_format_review?' do
    context "when status is 'collecting program information'" do
      before { submission.status = 'collecting program information' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_respond_to_format_review? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'collecting committee'" do
      before { submission.status = 'collecting committee' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_respond_to_format_review? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'collecting format review files'" do
      before { submission.status = 'collecting format review files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_respond_to_format_review? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'waiting for format review response'" do
      before { submission.status = 'waiting for format review response' }

      it "does not raise an exception" do
        giver = described_class.new(submission)
        expect { giver.can_respond_to_format_review? }.not_to raise_error
      end
    end

    context "when status is 'collecting final submission files'" do
      before { submission.status = 'collecting final submission files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_respond_to_format_review? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'waiting for final submission response'" do
      before { submission.status = 'waiting for final submission response' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_respond_to_format_review? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'waiting for publication release'" do
      before { submission.status = 'waiting for publication release' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_respond_to_format_review? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'released for publication'" do
      before { submission.status = 'released for publication' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_respond_to_format_review? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end
  end

  describe '#can_update_program_information?' do
    context "when status is 'collecting program information'" do
      before { submission.status = 'collecting program information' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_update_program_information? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'collecting committee'" do
      before { submission.status = 'collecting committee' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_update_program_information? }.not_to raise_error
      end
    end

    context "when status is 'collecting format review files'" do
      before { submission.status = 'collecting format review files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_update_program_information? }.not_to raise_error
      end
    end

    context "when status is 'waiting for format review response'" do
      before { submission.status = 'waiting for format review response' }

      it "does not raise an exception" do
        giver = described_class.new(submission)
        expect { giver.can_update_program_information? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'collecting final submission files'" do
      before { submission.status = 'collecting final submission files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_update_program_information? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'waiting for final submission response'" do
      before { submission.status = 'waiting for final submission response' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_update_program_information? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'waiting for publication release'" do
      before { submission.status = 'waiting for publication release' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_update_program_information? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'released for publication'" do
      before { submission.status = 'released for publication' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_update_program_information? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end
  end

  describe '#can_provide_new_committee?' do
    context "when status is 'collecting program information'" do
      before { submission.status = 'collecting program information' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_provide_new_committee? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'collecting committee'" do
      before { submission.status = 'collecting committee' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_provide_new_committee? }.not_to raise_error
      end
    end

    context "when status is 'collecting format review files'" do
      before { submission.status = 'collecting format review files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_provide_new_committee? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'waiting for format review response'" do
      before { submission.status = 'waiting for format review response' }

      it "does not raise an exception" do
        giver = described_class.new(submission)
        expect { giver.can_provide_new_committee? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'collecting final submission files'" do
      before { submission.status = 'collecting final submission files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_provide_new_committee? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'waiting for final submission response'" do
      before { submission.status = 'waiting for final submission response' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_provide_new_committee? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'waiting for publication release'" do
      before { submission.status = 'waiting for publication release' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_provide_new_committee? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'released for publication'" do
      before { submission.status = 'released for publication' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_provide_new_committee? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end
  end

  describe '#can_update_committee?' do
    context "when status is 'collecting program information'" do
      before { submission.status = 'collecting program information' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_update_committee? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'collecting committee'" do
      before { submission.status = 'collecting committee' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_update_committee? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'collecting format review files'" do
      before { submission.status = 'collecting format review files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_update_committee? }.not_to raise_error
      end
    end

    context "when status is 'waiting for format review response'" do
      before { submission.status = 'waiting for format review response' }

      it "does not raise an exception" do
        giver = described_class.new(submission)
        expect { giver.can_update_committee? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'collecting final submission files'" do
      before { submission.status = 'collecting final submission files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_update_committee? }.not_to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'waiting for final submission response'" do
      before { submission.status = 'waiting for final submission response' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_update_committee? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'waiting for publication release'" do
      before { submission.status = 'waiting for publication release' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_update_committee? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'released for publication'" do
      before { submission.status = 'released for publication' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_update_committee? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end
  end

  describe '#can_upload_format_review_files?' do
    context "when status is 'collecting program information'" do
      before { submission.status = 'collecting program information' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_upload_format_review_files? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'collecting committee'" do
      before { submission.status = 'collecting committee' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_upload_format_review_files? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'collecting format review files'" do
      before { submission.status = 'collecting format review files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_upload_format_review_files? }.not_to raise_error
      end
    end

    context "when status is 'waiting for format review response'" do
      before { submission.status = 'waiting for format review response' }

      it "does not raise an exception" do
        giver = described_class.new(submission)
        expect { giver.can_upload_format_review_files? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'collecting final submission files'" do
      before { submission.status = 'collecting final submission files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_upload_format_review_files? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'waiting for final submission response'" do
      before { submission.status = 'waiting for final submission response' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_upload_format_review_files? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'waiting for publication release'" do
      before { submission.status = 'waiting for publication release' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_upload_format_review_files? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'released for publication'" do
      before { submission.status = 'released for publication' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_upload_format_review_files? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end
  end

  describe '#can_review_program_information?' do
    context "when status is 'collecting program information'" do
      before { submission.status = 'collecting program information' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_review_program_information? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'collecting committee'" do
      before { submission.status = 'collecting committee' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_review_program_information? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'collecting format review files'" do
      before { submission.status = 'collecting format review files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_review_program_information? }.not_to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'waiting for format review response'" do
      before { submission.status = 'waiting for format review response' }

      it "does not raise an exception" do
        giver = described_class.new(submission)
        expect { giver.can_review_program_information? }.not_to raise_error
      end
    end

    context "when status is 'collecting final submission files'" do
      before { submission.status = 'collecting final submission files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_review_program_information? }.not_to raise_error
      end
    end

    context "when status is 'waiting for final submission response'" do
      before { submission.status = 'waiting for final submission response' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_review_program_information? }.not_to raise_error
      end
    end

    context "when status is 'waiting for publication release'" do
      before { submission.status = 'waiting for publication release' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_review_program_information? }.not_to raise_error
      end
    end

    context "when status is 'released for publication'" do
      before { submission.status = 'released for publication' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_review_program_information? }.not_to raise_error
      end
    end
  end

  describe '#can_create_or_edit_committee?' do
    context "when status is 'collecting program information'" do
      before { submission.status = 'collecting program information' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_create_or_edit_committee? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'collecting committee'" do
      before { submission.status = 'collecting committee' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_create_or_edit_committee? }.not_to raise_error
      end
    end

    context "when status is 'collecting format review files'" do
      before { submission.status = 'collecting format review files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_create_or_edit_committee? }.not_to raise_error
      end
    end

    context "when status is 'waiting for format review response'" do
      before { submission.status = 'waiting for format review response' }

      it "does not raise an exception" do
        giver = described_class.new(submission)
        expect { giver.can_create_or_edit_committee? }.not_to raise_error
      end
    end

    context "when status is 'collecting final submission files'" do
      before { submission.status = 'collecting final submission files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_create_or_edit_committee? }.not_to raise_error
      end
    end

    context "when status is 'waiting for final submission response'" do
      before { submission.status = 'waiting for final submission response' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_create_or_edit_committee? }.not_to raise_error
      end
    end

    context "when status is 'waiting for publication release'" do
      before { submission.status = 'waiting for publication release' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_create_or_edit_committee? }.not_to raise_error
      end
    end

    context "when status is 'released for publication'" do
      before { submission.status = 'released for publication' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_create_or_edit_committee? }.not_to raise_error
      end
    end
  end

  describe '#can_review_committee?' do
    context "when status is 'collecting program information'" do
      before { submission.status = 'collecting program information' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_review_committee? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'collecting committee'" do
      before { submission.status = 'collecting committee' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_review_committee? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'collecting format review files'" do
      before { submission.status = 'collecting format review files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_review_committee? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'waiting for format review response'" do
      before { submission.status = 'waiting for format review response' }

      it "does not raise an exception" do
        giver = described_class.new(submission)
        expect { giver.can_review_committee? }.not_to raise_error
      end
    end

    context "when status is 'collecting final submission files'" do
      before { submission.status = 'collecting final submission files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_review_committee? }.not_to raise_error
      end
    end

    context "when status is 'waiting for final submission response'" do
      before { submission.status = 'waiting for final submission response' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_review_committee? }.not_to raise_error
      end
    end

    context "when status is 'waiting for publication release'" do
      before { submission.status = 'waiting for publication release' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_review_committee? }.not_to raise_error
      end
    end

    context "when status is 'released for publication'" do
      before { submission.status = 'released for publication' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_review_committee? }.not_to raise_error
      end
    end
  end

  describe '#can_review_format_review_files?' do
    context "when status is 'collecting program information'" do
      before { submission.status = 'collecting program information' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_review_format_review_files? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'collecting committee'" do
      before { submission.status = 'collecting committee' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_review_format_review_files? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'collecting format review files'" do
      before { submission.status = 'collecting format review files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_review_format_review_files? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'waiting for format review response'" do
      before { submission.status = 'waiting for format review response' }

      it "does not raise an exception" do
        giver = described_class.new(submission)
        expect { giver.can_review_format_review_files? }.not_to raise_error
      end
    end

    context "when status is 'collecting final submission files'" do
      before { submission.status = 'collecting final submission files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_review_format_review_files? }.not_to raise_error
      end
    end

    context "when status is 'waiting for final submission response'" do
      before { submission.status = 'waiting for final submission response' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_review_format_review_files? }.not_to raise_error
      end
    end

    context "when status is 'waiting for publication release'" do
      before { submission.status = 'waiting for publication release' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_review_format_review_files? }.not_to raise_error
      end
    end

    context "when status is 'released for publication'" do
      before { submission.status = 'released for publication' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_review_format_review_files? }.not_to raise_error
      end
    end
  end

  describe '#can_upload_final_submission_files??' do
    context "when status is 'collecting program information'" do
      before { submission.status = 'collecting program information' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_upload_final_submission_files? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'collecting committee'" do
      before { submission.status = 'collecting committee' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_upload_final_submission_files? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'collecting format review files'" do
      before { submission.status = 'collecting format review files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_upload_final_submission_files? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'waiting for format review response'" do
      before { submission.status = 'waiting for format review response' }

      it "does not raise an exception" do
        giver = described_class.new(submission)
        expect { giver.can_upload_final_submission_files? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'collecting final submission files'" do
      before { submission.status = 'collecting final submission files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_upload_final_submission_files? }.not_to raise_error
      end
    end

    context "when status is 'waiting for final submission response'" do
      before { submission.status = 'waiting for final submission response' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_upload_final_submission_files? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'waiting for publication release'" do
      before { submission.status = 'waiting for publication release' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_upload_final_submission_files? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'released for publication'" do
      before { submission.status = 'released for publication' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_upload_final_submission_files? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end
  end

  describe '#can_review_final_submission_files?' do
    context "when status is 'collecting program information'" do
      before { submission.status = 'collecting program information' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_review_final_submission_files? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'collecting committee'" do
      before { submission.status = 'collecting committee' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_review_final_submission_files? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'collecting format review files'" do
      before { submission.status = 'collecting format review files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_review_final_submission_files? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'waiting for format review response'" do
      before { submission.status = 'waiting for format review response' }

      it "does not raise an exception" do
        giver = described_class.new(submission)
        expect { giver.can_review_final_submission_files? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'collecting final submission files'" do
      before { submission.status = 'collecting final submission files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_review_final_submission_files? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'waiting for final submission response'" do
      before { submission.status = 'waiting for final submission response' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_review_final_submission_files? }.not_to raise_error
      end
    end

    context "when status is 'waiting for publication release'" do
      before { submission.status = 'waiting for publication release' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_review_final_submission_files? }.not_to raise_error
      end
    end

    context "when status is 'released for publication'" do
      before { submission.status = 'released for publication' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_review_final_submission_files? }.not_to raise_error
      end
    end
  end

  describe '#can_respond_to_final_submission?' do
    context "when status is 'collecting program information'" do
      before { submission.status = 'collecting program information' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_respond_to_final_submission? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'collecting committee'" do
      before { submission.status = 'collecting committee' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_respond_to_final_submission? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'collecting format review files'" do
      before { submission.status = 'collecting format review files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_respond_to_final_submission? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'waiting for format review response'" do
      before { submission.status = 'waiting for format review response' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_respond_to_final_submission? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'collecting final submission files'" do
      before { submission.status = 'collecting final submission files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_respond_to_final_submission? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'waiting for final submission response'" do
      before { submission.status = 'waiting for final submission response' }

      it "does not raise an exception" do
        giver = described_class.new(submission)
        expect { giver.can_respond_to_final_submission? }.not_to raise_error
      end
    end

    context "when status is 'waiting for publication release'" do
      before { submission.status = 'waiting for publication release' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_respond_to_final_submission? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'released for publication'" do
      before { submission.status = 'released for publication' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_respond_to_final_submission? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end
  end

  describe '#can_release_for_publication?' do
    context "when status is 'collecting program information'" do
      before { submission.status = 'collecting program information' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_release_for_publication? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'collecting committee'" do
      before { submission.status = 'collecting committee' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_release_for_publication? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'collecting format review files'" do
      before { submission.status = 'collecting format review files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_release_for_publication? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'waiting for format review response'" do
      before { submission.status = 'waiting for format review response' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_release_for_publication? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'collecting final submission files'" do
      before { submission.status = 'collecting final submission files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_release_for_publication? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'waiting for final submission response'" do
      before { submission.status = 'waiting for final submission response' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_release_for_publication? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'waiting for publication release'" do
      before { submission.status = 'waiting for publication release' }

      it "does not raise an exception" do
        giver = described_class.new(submission)
        expect { giver.can_release_for_publication? }.not_to raise_error
      end
    end

    context "when status is 'released for publication'" do
      before { submission.status = 'released for publication', submission.access_level = 'open_access' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_release_for_publication? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end
  end

  describe '#can_unrelease_for_publication?' do
    context "when status is 'collecting program information'" do
      before { submission.status = 'collecting program information' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_unrelease_for_publication? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'collecting committee'" do
      before { submission.status = 'collecting committee' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_unrelease_for_publication? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'collecting format review files'" do
      before { submission.status = 'collecting format review files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_unrelease_for_publication? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'waiting for format review response'" do
      before { submission.status = 'waiting for format review response' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_unrelease_for_publication? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'collecting final submission files'" do
      before { submission.status = 'collecting final submission files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_unrelease_for_publication? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'waiting for final submission response'" do
      before { submission.status = 'waiting for final submission response' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_unrelease_for_publication? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'waiting for publication release'" do
      before { submission.status = 'waiting for publication release' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.can_unrelease_for_publication? }.to raise_error(SubmissionStatusGiver::AccessForbidden)
      end
    end

    context "when status is 'released for publication'" do
      before { submission.status = 'released for publication' }

      it "does not raise an exception" do
        giver = described_class.new(submission)
        expect { giver.can_unrelease_for_publication? }.not_to raise_error
      end
    end
  end

  describe '#collecting_committee!' do
    context "when status is 'collecting program information'" do
      before { submission.status = 'collecting program information' }

      it "updates status to 'collecting committee'" do
        giver = described_class.new(submission)
        giver.collecting_committee!
        expect(submission.status).to eq 'collecting committee'
      end
    end

    context "when status is 'collecting committee'" do
      before { submission.status = 'collecting committee' }

      it "does not change the status" do
        giver = described_class.new(submission)
        giver.collecting_committee!
        expect(submission.status).to eq 'collecting committee'
      end
    end

    context "when status is 'collecting format review files'" do
      before { submission.status = 'collecting format review files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.collecting_committee! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'waiting for format review response'" do
      before { submission.status = 'waiting for format review response' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.collecting_committee! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'collecting final submission files'" do
      before { submission.status = 'collecting final submission files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.collecting_committee! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'waiting for final submission response'" do
      before { submission.status = 'waiting for final submission response' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.collecting_committee! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'waiting for publication release'" do
      before { submission.status = 'waiting for publication release' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.collecting_committee! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'released for publication'" do
      before { submission.status = 'released for publication' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.collecting_committee! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end
  end

  describe '#collecting_format_review_files!' do
    context "when status is 'collecting program information'" do
      before { submission.status = 'collecting program information' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.collecting_format_review_files! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'collecting committee'" do
      before { submission.status = 'collecting committee' }

      it "updates status to 'collecting format review files'" do
        giver = described_class.new(submission)
        giver.collecting_format_review_files!
        expect(submission.status).to eq 'collecting format review files'
      end
    end

    context "when status is 'collecting format review files'" do
      before { submission.status = 'collecting format review files' }

      it "does not change the status" do
        giver = described_class.new(submission)
        giver.collecting_format_review_files!
        expect(submission.status).to eq 'collecting format review files'
      end
    end

    context "when status is 'waiting for format review response'" do
      before { submission.status = 'waiting for format review response' }

      it "updates status to 'collecting format review files rejected'" do
        giver = described_class.new(submission)
        giver.collecting_format_review_files_rejected!
        expect(submission.status).to eq 'collecting format review files rejected'
      end
    end

    context "when status is 'collecting final submission files'" do
      before { submission.status = 'collecting final submission files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.collecting_format_review_files! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'waiting for final submission response'" do
      before { submission.status = 'waiting for final submission response' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.collecting_format_review_files! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'waiting for publication release'" do
      before { submission.status = 'waiting for publication release' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.collecting_format_review_files! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'released for publication'" do
      before { submission.status = 'released for publication' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.collecting_format_review_files! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end
  end

  describe '#waiting_for_format_review_response!' do
    context "when status is 'collecting program information'" do
      before { submission.status = 'collecting program information' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.waiting_for_format_review_response! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'collecting committee'" do
      before { submission.status = 'collecting committee' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.waiting_for_format_review_response! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'collecting format review files'" do
      before { submission.status = 'collecting format review files' }

      it "updates status to 'waiting for format review response'" do
        giver = described_class.new(submission)
        giver.waiting_for_format_review_response!
        expect(submission.status).to eq 'waiting for format review response'
      end
    end

    context "when status is 'waiting for format review response'" do
      before { submission.status = 'waiting for format review response' }

      it "does not change the status" do
        giver = described_class.new(submission)
        giver.waiting_for_format_review_response!
        expect(submission.status).to eq 'waiting for format review response'
      end
    end

    context "when status is 'collecting final submission files'" do
      before { submission.status = 'collecting final submission files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.waiting_for_format_review_response! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'waiting for final submission response'" do
      before { submission.status = 'waiting for final submission response' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.waiting_for_format_review_response! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'waiting for publication release'" do
      before { submission.status = 'waiting for publication release' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.waiting_for_format_review_response! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'released for publication'" do
      before { submission.status = 'released for publication' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.waiting_for_format_review_response! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end
  end

  describe '#collecting_final_submission_files!' do
    context "when status is 'collecting program information'" do
      before { submission.status = 'collecting program information' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.collecting_final_submission_files! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'collecting committee'" do
      before { submission.status = 'collecting committee' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.collecting_final_submission_files! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'collecting format review files'" do
      before { submission.status = 'collecting format review files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.collecting_final_submission_files! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'waiting for format review response'" do
      before { submission.status = 'waiting for format review response' }

      it "updates status to 'collecting final submission files'" do
        giver = described_class.new(submission)
        giver.collecting_final_submission_files!
        expect(submission.status).to eq 'collecting final submission files'
      end
    end

    context "when status is 'collecting final submission files'" do
      before { submission.status = 'collecting final submission files' }

      it "does not change the status" do
        giver = described_class.new(submission)
        giver.collecting_final_submission_files!
        expect(submission.status).to eq 'collecting final submission files'
      end
    end

    context "when status is 'waiting for final submission response'" do
      before { submission.status = 'waiting for final submission response' }

      it "updates status to 'collecting final submission files'" do
        giver = described_class.new(submission)
        giver.collecting_final_submission_files!
        expect(submission.status).to eq 'collecting final submission files'
      end
    end

    context "when status is 'waiting for publication release'" do
      before { submission.status = 'waiting for publication release' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.waiting_for_final_submission_response! }.not_to raise_error
      end
    end

    context "when status is 'released for publication'" do
      before { submission.status = 'released for publication' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.collecting_final_submission_files! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end
  end

  describe '#waiting_for_committee_review!' do
    context "when status is 'collecting final submission files'" do
      before { submission.status = 'collecting final submission files' }

      it "updates status to 'waiting for committee review'" do
        giver = described_class.new(submission)
        giver.waiting_for_committee_review!
        expect(submission.status).to eq 'waiting for committee review'
      end
    end

    context "when status is 'collecting final submission files'" do
      before { submission.status = 'collecting final submission files' }

      it "updates status to 'waiting for committee review'" do
        giver = described_class.new(submission)
        giver.waiting_for_committee_review!
        expect(submission.status).to eq 'waiting for committee review'
      end
    end
  end

  describe '#waiting_for_final_submission_response!' do
    context "when status is 'collecting program information'" do
      before { submission.status = 'collecting program information' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.waiting_for_final_submission_response! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'collecting committee'" do
      before { submission.status = 'collecting committee' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.waiting_for_final_submission_response! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'collecting format review files'" do
      before { submission.status = 'collecting format review files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.waiting_for_final_submission_response! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'waiting for format review response'" do
      before { submission.status = 'waiting for format review response' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.waiting_for_final_submission_response! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'collecting final submission files'" do
      before { submission.status = 'collecting final submission files' }

      it "updates status to 'waiting for final submission response'" do
        giver = described_class.new(submission)
        expect { giver.waiting_for_final_submission_response! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'waiting for final submission response'" do
      before { submission.status = 'waiting for final submission response' }

      it "does not change the status" do
        giver = described_class.new(submission)
        giver.waiting_for_final_submission_response!
        expect(submission.status).to eq 'waiting for final submission response'
      end
    end

    context "when status is 'waiting for publication release'" do
      before { submission.status = 'waiting for publication release' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.waiting_for_final_submission_response! }.not_to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'released for publication'" do
      before { submission.status = 'released for publication' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.waiting_for_final_submission_response! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end
  end

  describe '#waiting_for_publication_release!' do
    context "when status is 'collecting program information'" do
      before { submission.status = 'collecting program information' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.waiting_for_publication_release! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'collecting committee'" do
      before { submission.status = 'collecting committee' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.waiting_for_publication_release! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'collecting format review files'" do
      before { submission.status = 'collecting format review files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.waiting_for_publication_release! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'waiting for format review response'" do
      before { submission.status = 'waiting for format review response' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.waiting_for_publication_release! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'collecting final submission files'" do
      before { submission.status = 'collecting final submission files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.waiting_for_publication_release! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'waiting for final submission response'" do
      before { submission.status = 'waiting for final submission response' }

      it "updates status to 'waiting for publication release'" do
        giver = described_class.new(submission)
        giver.waiting_for_publication_release!
        expect(submission.status).to eq 'waiting for publication release'
      end
    end

    context "when status is 'waiting for publication release'" do
      before { submission.status = 'waiting for publication release' }

      it "does not change the status" do
        giver = described_class.new(submission)
        giver.waiting_for_publication_release!
        expect(submission.status).to eq 'waiting for publication release'
      end
    end

    context "when status is 'released for publication'" do
      before { submission.status = 'released for publication' }

      it "changes the status to 'waiting for publication release'" do
        giver = described_class.new(submission)
        giver.waiting_for_publication_release!
        expect(submission.status).to eq 'waiting for publication release'
      end
    end
  end

  describe '#released_for_publication!' do
    context "when status is 'collecting program information'" do
      before { submission.status = 'collecting program information' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.released_for_publication! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'collecting committee'" do
      before { submission.status = 'collecting committee' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.released_for_publication! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'collecting format review files'" do
      before { submission.status = 'collecting format review files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.released_for_publication! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'waiting for format review response'" do
      before { submission.status = 'waiting for format review response' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.released_for_publication! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'collecting final submission files'" do
      before { submission.status = 'collecting final submission files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.released_for_publication! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'waiting for final submission response'" do
      before { submission.status = 'waiting for final submission response' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.released_for_publication! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'waiting for publication release'" do
      before { submission.status = 'waiting for publication release' }

      it "updates status to 'released for publication'" do
        giver = described_class.new(submission)
        giver.released_for_publication!
        expect(submission.status).to eq 'released for publication'
      end
    end

    context "when status is 'released for publication'" do
      before { submission.status = 'released for publication' }

      it "does not change the status" do
        giver = described_class.new(submission)
        giver.released_for_publication!
        expect(submission.status).to eq 'released for publication'
      end
    end
  end

  describe '#unreleased_for_publication!' do
    context "when status is 'collecting program information'" do
      before { submission.status = 'collecting program information' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.unreleased_for_publication! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'collecting committee'" do
      before { submission.status = 'collecting committee' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.unreleased_for_publication! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'collecting format review files'" do
      before { submission.status = 'collecting format review files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.unreleased_for_publication! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'waiting for format review response'" do
      before { submission.status = 'waiting for format review response' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.unreleased_for_publication! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'collecting final submission files'" do
      before { submission.status = 'collecting final submission files' }

      it "raises an exception" do
        giver = described_class.new(submission)
        expect { giver.unreleased_for_publication! }.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'waiting for final submission response'" do
      before { submission.status = 'waiting for final submission response' }

      it "changes the status to 'waiting for publication release'" do
        giver = described_class.new(submission)
        giver.unreleased_for_publication!
        expect(submission.status).to eq 'waiting for publication release'
        #        expect {giver.unreleased_for_publication!}.to raise_error(SubmissionStatusGiver::InvalidTransition)
      end
    end

    context "when status is 'waiting for publication release'" do
      before { submission.status = 'waiting for publication release' }

      it "does not change the status" do
        giver = described_class.new(submission)
        giver.unreleased_for_publication!
        expect(submission.status).to eq 'waiting for publication release'
      end
    end

    context "when status is 'released for publication'" do
      before { submission.status = 'released for publication' }

      it "updates status to 'waiting for publication release" do
        giver = described_class.new(submission)
        giver.unreleased_for_publication!
        expect(submission.status).to eq 'waiting for publication release'
      end
    end
  end
end
