# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminStatuses do
  describe '#admin_status' do
    context 'when the admin status is format_review_incomplete' do
      it 'returns the correct label' do
        status = 'format_review_incomplete'
        submission = Submission.new(status: 'collecting program information')
        expect(submission.admin_status).to eq I18n.t!("#{current_partner.id}.admin_filters.#{status}.title")
      end
    end

    context 'when the admin status is format_review_submitted' do
      it 'returns the correct label' do
        status = 'format_review_submitted'
        submission = Submission.new(status: 'waiting for format review response')
        expect(submission.admin_status).to eq I18n.t!("#{current_partner.id}.admin_filters.#{status}.title")
      end
    end

    context 'when the admin status is format_review_completed' do
      it 'returns the correct label' do
        status = 'format_review_completed'
        submission = Submission.new(status: 'collecting final submission files')
        expect(submission.admin_status).to eq I18n.t!("#{current_partner.id}.admin_filters.#{status}.title")
      end
    end

    context 'when the admin status is final_submission_pending' do
      it 'returns the correct label' do
        status = 'final_submission_pending'
        submission = Submission.new(status: 'waiting for head of program review')
        expect(submission.admin_status).to eq I18n.t!("#{current_partner.id}.admin_filters.#{status}.title")
      end
    end

    context 'when the admin status is committee_review_rejected' do
      it 'returns the correct label' do
        status = 'committee_review_rejected'
        submission = Submission.new(status: 'waiting for committee review rejected')
        expect(submission.admin_status).to eq I18n.t!("#{current_partner.id}.admin_filters.#{status}.title")
      end
    end

    context 'when the admin status is final_submission_submitted' do
      it 'returns the correct label' do
        status = 'final_submission_submitted'
        submission = Submission.new(status: 'waiting for final submission response')
        expect(submission.admin_status).to eq I18n.t!("#{current_partner.id}.admin_filters.#{status}.title")
      end
    end

    context 'when the admin status is final_submission_incomplete' do
      it 'returns the correct label' do
        status = 'final_submission_incomplete'
        submission = Submission.new(status: 'collecting final submission files rejected',
                                    final_submission_rejected_at: DateTime.now)
        expect(submission.admin_status).to eq I18n.t!("#{current_partner.id}.admin_filters.#{status}.title")
      end
    end

    context 'when the admin status is final_submission_approved' do
      it 'returns the correct label' do
        status = 'final_submission_approved'
        submission = Submission.new(status: 'waiting for publication release')
        expect(submission.admin_status).to eq I18n.t!("#{current_partner.id}.admin_filters.#{status}.title")
      end
    end

    context 'when the admin status is final_submission_on_hold' do
      it 'returns the correct label' do
        status = 'final_submission_on_hold'
        submission = Submission.new(status: 'waiting in final submission on hold')
        expect(submission.admin_status).to eq I18n.t!("#{current_partner.id}.admin_filters.#{status}.title")
      end
    end

    context 'when the admin status is final_restricted_institution' do
      context 'when access level is restricted to institution' do
        it 'returns the correct label' do
          status = 'final_restricted_institution'
          submission = Submission.new(status: 'released for publication!!!',
                                      access_level: 'restricted_to_institution')
          expect(submission.admin_status).to eq I18n.t!("#{current_partner.id}.admin_filters.#{status}.title")
        end
      end

      context 'when access level is restricted liberal arts' do
        it 'returns the correct label' do
          status = 'final_restricted_institution'
          submission = Submission.new(status: 'released for publication!!!',
                                      access_level: 'restricted_liberal_arts')
          expect(submission.admin_status).to eq I18n.t!("#{current_partner.id}.admin_filters.#{status}.title")
        end
      end
    end

    context 'when the admin status is final_withheld' do
      it 'returns the correct label' do
        status = 'final_withheld'
        submission = Submission.new(status: 'released for publication!!!',
                                    access_level: 'restricted')
        expect(submission.admin_status).to eq I18n.t!("#{current_partner.id}.admin_filters.#{status}.title")
      end
    end

    context 'when the admin status is released_for_publication' do
      it 'returns the correct label' do
        status = 'released_for_publication'
        submission = Submission.new(status: 'released for publication!!!')
        expect(submission.admin_status).to eq I18n.t!("#{current_partner.id}.admin_filters.#{status}.title")
      end
    end
  end
end
