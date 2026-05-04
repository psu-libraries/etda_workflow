# frozen_string_literal: true

require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe FormatReviewUpdateService, type: :model do
  let(:committee_member) { FactoryBot.create :committee_member, created_at: DateTime.yesterday }

  context 'it processes approved format review submissions', :honors, :milsch, :sset do
    it 'approves a format review' do
      submission = FactoryBot.create :submission, :waiting_for_format_review_response, committee_members: [committee_member]
      params = ActionController::Parameters.new
      params[:submission] = submission.attributes
      params[:submission][:committee_members_attributes] = { "0" => submission.committee_members.first.attributes }
      params[:approved] = true
      params[:submission][:committee_members_attributes]["0"]['is_voting'] = false
      params[:submission][:committee_members_attributes]["0"]['status'] = 'approved'
      params[:submission][:federal_funding] = false
      title = submission.title
      format_review_update_service = described_class.new(params, submission, 'testuser123')
      result = format_review_update_service.respond_format_review
      expect(result[:msg]).to eql("The submission\'s format review information was successfully approved and returned to the author to collect final submission information.")
      expect(result[:redirect_path]).to eql("/admin/#{submission.degree_type.slug}/format_review_submitted")
      expect(submission.status).to eq('collecting final submission files')
      expect(submission.title).to eq(title)
      expect(submission.committee_members.first.is_voting).to be(false)
      expect(submission.committee_members.first.status).to eq('approved')
      expect(submission.committee_members.first.notes).to match(/\nThe admin user testuser123 changed Review Status to 'Approved' at: .*\n\nThe admin user testuser123 changed Voting Attribute to 'False' at:/)
      expect(submission.federal_funding).to be false
      expect(WorkflowMailer.deliveries.count).to eq 1 if current_partner.graduate? || current_partner.sset?
      expect(WorkflowMailer.deliveries.count).to eq 0 if current_partner.milsch?
      # Honors college has requested that we send the format review approved email to committee_members as well
      if current_partner.honors?
        committee_members = submission.committee_members
        expect(WorkflowMailer.deliveries[0].to).to eq([committee_members.first.email])
        expect(WorkflowMailer.deliveries[1].to).to eq([submission.author.psu_email_address])
        expect(WorkflowMailer.deliveries.count).to eq(1 + committee_members.count)
      end
    end
  end

  context 'it processes rejected format review submissions', :honors, :milsch, :sset do
    it 'rejects a format review' do
      submission = FactoryBot.create :submission, :waiting_for_format_review_response, committee_members: [committee_member]
      params = ActionController::Parameters.new
      params[:submission] = submission.attributes
      params[:submission][:committee_members_attributes] = { "0" => submission.committee_members.first.attributes }
      params[:rejected] = true
      params[:submission][:committee_members_attributes]["0"]['is_voting'] = false
      semester = submission.semester
      format_review_update_service = described_class.new(params, submission, 'testuser123')
      result = format_review_update_service.respond_format_review
      expect(result[:msg]).to eql("The submission\'s format review information was successfully rejected and returned to the author for revision.")
      expect(result[:redirect_path]).to eql("/admin/#{submission.degree_type.slug}/format_review_submitted")
      expect(submission.status).to eq('collecting format review files rejected')
      expect(submission.semester).to eq(semester)
      expect(submission.committee_members.first.is_voting).to be(false)
      expect(submission.committee_members.first.notes).to match(/\nThe admin user testuser123 changed Voting Attribute to 'False' at:/)
      expect(WorkflowMailer.deliveries.count).to eq 1 unless current_partner.milsch?
      expect(WorkflowMailer.deliveries.count).to eq 0 if current_partner.milsch?
    end
  end

  context 'it updates the record' do
    it 'updates a format review' do
      submission = FactoryBot.create :submission, :waiting_for_format_review_response, committee_members: [committee_member]
      original_title = submission.title
      params = ActionController::Parameters.new
      params[:submission] = submission.attributes
      params[:submission][:committee_members_attributes] = { "0" => submission.committee_members.first.attributes }
      params[:update_format_review] = true
      params[:submission][:title] = 'a different title'
      params[:submission][:format_review_notes] = 'a note to you'
      params[:submission][:committee_members_attributes]["0"]['status'] = 'rejected'
      format_review_update_service = described_class.new(params, submission, 'testuser123')
      result = format_review_update_service.update_record
      expect(result[:msg]).to eql("The submission was successfully updated.")
      expect(result[:redirect_path]).to eql(admin_edit_submission_path(submission.id.to_s))
      expect(submission.title).to eq('a different title')
      expect(submission.format_review_notes).to eq('a note to you')
      expect(original_title == submission.title).to be_falsey
      expect(submission.committee_members.first.status).to eq('rejected')
    end
  end

  context 'it updates a format review submission and status' do
    it 'approves a format review' do
      submission = FactoryBot.create :submission, :waiting_for_format_review_response, committee_members: [committee_member]
      params = ActionController::Parameters.new
      params[:submission] = submission.attributes
      params[:submission][:committee_members_attributes] = { "0" => submission.committee_members.first.attributes }
      params[:approved] = true
      params[:submission][:title] = 'another different title'
      params[:submission][:format_review_notes] = 'another note to you'
      params[:submission][:committee_members_attributes]["0"]['is_voting'] = false
      format_review_update_service = described_class.new(params, submission, 'testuser123')
      result = format_review_update_service.respond_format_review
      expect(result[:msg]).to eql("The submission's format review information was successfully approved and returned to the author to collect final submission information.")
      expect(result[:redirect_path]).to eql("/admin/#{submission.degree_type.slug}/format_review_submitted")
      expect(submission.status).to eq('collecting final submission files')
      expect(submission.title == 'another different title').to be_truthy
      expect(submission.committee_members.first.is_voting).to be(false)
    end
  end
end
