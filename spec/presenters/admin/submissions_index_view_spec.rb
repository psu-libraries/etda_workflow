require 'presenters/presenters_spec_helper'
RSpec.describe Admin::SubmissionsIndexView do
  let(:degree_type) { DegreeType.default.slug }
  let(:semester) { Semester.current }
  let(:view) { described_class.new(degree_type, scope, nil, semester) }

  describe '#default_semester' do
    context 'when semester is nil and submission is not released/to be released' do
      let(:scope) { 'format_review_incomplete' }
      let(:semester) { nil }

      it "returns 'All Semesters'" do
        expect(view.default_semester).to eq 'All Semesters'
      end
    end

    context 'when semester is nil and submission is released' do
      let(:scope) { 'released_for_publication' }
      let(:semester) { nil }

      it "returns current semester" do
        expect(view.default_semester).to eq Semester.current
      end
    end

    context 'when semester is given and submission is not released/to be released' do
      let(:scope) { 'format_review_incomplete' }
      let(:semester) { "Fall 2018" }

      it "returns given semester" do
        expect(view.default_semester).to eq "Fall 2018"
      end
    end

    context 'when semester is given and submission is to be released' do
      let(:scope) { 'final_submission_to_be_released' }
      let(:semester) { "Fall 2018" }

      it 'returns given semester' do
        expect(view.default_semester).to eq "Fall 2018"
      end
    end
  end

  describe '#table_header_partial_path' do
    let(:scope) { 'format_review_incomplete' }

    it "returns the path to the view partial for the scoped view's table's header" do
      expect(view.table_header_partial_path).to eq 'admin/submissions/table_headers/format_review_incomplete'
    end
  end

  describe '#table_body_partial_path' do
    let(:scope) { 'format_review_incomplete' }

    it "returns the path to the view partial for the scoped view's table's body" do
      expect(view.table_body_partial_path).to eq 'admin/submissions/table_bodies/format_review_incomplete'
    end
  end

  describe '#title' do
    context "when scope is format review is incomplete" do
      let(:scope) { 'format_review_incomplete' }

      it "returns 'Format Review is Incomplete'" do
        expect(view.title).to eq I18n.t("#{current_partner.id}.admin_filters.#{scope}.title")
      end
    end

    context "when scope is format review is submitted" do
      let(:scope) { 'format_review_submitted' }

      it "returns 'Format Review is Submitted'" do
        expect(view.title).to eq I18n.t("#{current_partner.id}.admin_filters.#{scope}.title")
      end
    end

    context "when scope is format review is completed" do
      let(:scope) { 'format_review_completed' }

      it "returns 'Format Review is Completed'" do
        expect(view.title).to eq I18n.t("#{current_partner.id}.admin_filters.#{scope}.title")
      end
    end

    context "when scope is final submission is incomplete" do
      let(:scope) { 'final_submission_incomplete' }

      it "returns 'Final Submission is Incomplete'" do
        expect(view.title).to eq I18n.t("#{current_partner.id}.admin_filters.#{scope}.title")
      end
    end

    context "when scope is final submission is submitted" do
      let(:scope) { 'final_submission_submitted' }

      it "returns 'Final Submission is Submitted'" do
        expect(view.title).to eq I18n.t("#{current_partner.id}.admin_filters.#{scope}.title")
      end
    end

    context "when scope is final submission is approved" do
      let(:scope) { 'final_submission_approved' }

      it "returns 'Final Submission is Approved'" do
        expect(view.title).to eq I18n.t("#{current_partner.id}.admin_filters.#{scope}.title")
      end
    end

    context "when scope is final submission on hold" do
      let(:scope) { 'final_submission_on_hold' }

      it "returns 'Final Submission is On Hold'" do
        expect(view.title).to eq I18n.t("#{current_partner.id}.admin_filters.#{scope}.title")
      end
    end

    context "when scope is released for publication" do
      let(:scope) { 'released_for_publication' }

      it "returns 'Released eTDs'" do
        expect(view.title).to eq I18n.t("#{current_partner.id}.admin_filters.#{scope}.title", submission: 'Dissertations')
      end
    end

    context "when scope is final is restricted by institution" do
      let(:scope) { 'final_restricted_institution' }

      it "returns 'Final Submission is Restricted to Penn State'" do
        expect(view.title).to eq I18n.t("#{current_partner.id}.admin_filters.#{scope}.title")
      end
    end

    context "when scope is final restricted" do
      let(:scope) { 'final_withheld' }

      it "returns 'Final Submission is Restricted'" do
        expect(view.title).to eq I18n.t("#{current_partner.id}.admin_filters.#{scope}.title", submission: 'Dissertations')
      end
    end
  end

  describe '#id' do
    context "when scope is format review is incomplete" do
      let(:scope) { 'format_review_incomplete' }

      it "returns 'incomplete-format-review-submissions-index'" do
        expect(view.id).to eq 'incomplete-format-review-submissions-index'
      end
    end

    context "when scope is format review is submitted" do
      let(:scope) { 'format_review_submitted' }

      it "returns 'submitted-format-review-submissions-index'" do
        expect(view.id).to eq 'submitted-format-review-submissions-index'
      end
    end

    context "when scope is format review is completed" do
      let(:scope) { 'format_review_completed' }

      it "returns 'completed-format-review-submissions-index'" do
        expect(view.id).to eq 'completed-format-review-submissions-index'
      end
    end

    context "when scope is final submission is incomplete" do
      let(:scope) { 'final_submission_incomplete' }

      it "returns 'incomplete-final-submission-submissions-index'" do
        expect(view.id).to eq 'incomplete-final-submission-submissions-index'
      end
    end

    context "when scope is final submission is submitted" do
      let(:scope) { 'final_submission_submitted' }

      it "returns 'submitted-final-submission-submissions-index'" do
        expect(view.id).to eq 'submitted-final-submission-submissions-index'
      end
    end

    context "when scope is final submission is approved" do
      let(:scope) { 'final_submission_approved' }

      it "returns 'approved-final-submission-submissions-index'" do
        expect(view.id).to eq 'approved-final-submission-submissions-index'
      end
    end

    context "when scope is final submission is on hold" do
      let(:scope) { 'final_submission_on_hold' }

      it "returns 'on-hold-final-submission-submissions-index'" do
        expect(view.id).to eq 'on-hold-final-submission-submissions-index'
      end
    end

    context "when scope is released for publication" do
      let(:scope) { 'released_for_publication' }

      it "returns 'released-for-publication-submissions-index'" do
        expect(view.id).to eq 'released-for-publication-submissions-index'
      end
    end

    context "when scope is final restricted to institution" do
      let(:scope) { 'final_restricted_institution' }

      it "returns 'final-restricted-institution-index'" do
        expect(view.id).to eq 'final-restricted-institution-index'
      end
    end

    context "when scope is final is restricted" do
      let(:scope) { 'final_withheld' }

      it "returns 'final-withheld-index'" do
        expect(view.id).to eq 'final-withheld-index'
      end
    end
  end

  describe '#render_additional_bulk_actions?' do
    context "when scope is format review is incomplete" do
      let(:scope) { 'format_review_incomplete' }

      it "returns false" do
        expect(view).not_to be_render_additional_bulk_actions
      end
    end

    context "when scope is format review is submitted" do
      let(:scope) { 'format_review_submitted' }

      it "returns false" do
        expect(view).not_to be_render_additional_bulk_actions
      end
    end

    context "when scope is format review is completed" do
      let(:scope) { 'format_review_completed' }

      it "returns false" do
        expect(view).not_to be_render_additional_bulk_actions
      end
    end

    context "when scope is final submission is incomplete" do
      let(:scope) { 'final_submission_incomplete' }

      it "returns false" do
        expect(view).not_to be_render_additional_bulk_actions
      end
    end

    context "when scope is final submission is submitted" do
      let(:scope) { 'final_submission_submitted' }

      it "returns false" do
        expect(view).not_to be_render_additional_bulk_actions
      end
    end

    context "when scope is final submission is approved" do
      let(:scope) { 'final_submission_approved' }

      it "returns true" do
        expect(view).to be_render_additional_bulk_actions
      end
    end

    context "when scope is final submission is on hold" do
      let(:scope) { 'final_submission_on_hold' }

      it "returns true" do
        expect(view).not_to be_render_additional_bulk_actions
      end
    end

    context "when scope is released for publication" do
      let(:scope) { 'released_for_publication' }

      it "returns false" do
        expect(view).not_to be_render_additional_bulk_actions
      end
    end

    context "when scope is final is restricted by institution" do
      let(:scope) { 'final_restricted_institution' }

      it "returns true" do
        expect(view.render_additional_bulk_actions?).to be true
      end
    end

    context "when scope is final restricted" do
      let(:scope) { 'final_withheld' }

      it "returns true" do
        expect(view.render_additional_bulk_actions?).to be true
      end
    end
  end

  describe '#additional_bulk_actions_path' do
    context "when scope is format review is incomplete" do
      let(:scope) { 'format_review_incomplete' }

      it "returns nil" do
        expect(view.additional_bulk_actions_path).to be_nil
      end
    end

    context "when scope is format review is submitted" do
      let(:scope) { 'format_review_submitted' }

      it "returns nil" do
        expect(view.additional_bulk_actions_path).to be_nil
      end
    end

    context "when scope is format review is completed" do
      let(:scope) { 'format_review_completed' }

      it "returns nil" do
        expect(view.additional_bulk_actions_path).to be_nil
      end
    end

    context "when scope is final submission is incomplete" do
      let(:scope) { 'final_submission_incomplete' }

      it "returns nil" do
        expect(view.additional_bulk_actions_path).to be_nil
      end
    end

    context "when scope is final submission is submitted" do
      let(:scope) { 'final_submission_submitted' }

      it "returns nil" do
        expect(view.additional_bulk_actions_path).to be_nil
      end
    end

    context "when scope is final submission is approved" do
      let(:scope) { 'final_submission_approved' }

      it "returns 'table_bulk_actions/final_submission_approved'" do
        expect(view.additional_bulk_actions_path).to eq 'admin/submissions/table_bulk_actions/final_submission_approved'
      end
    end

    context "when scope is final submission is on hold" do
      let(:scope) { 'final_submission_on_hold' }

      it "returns 'table_bulk_actions/final_submission_on_hold'" do
        expect(view.additional_bulk_actions_path).to be_nil
      end
    end

    context "when scope is released for publication" do
      let(:scope) { 'released_for_publication' }

      it "returns nil" do
        expect(view.additional_bulk_actions_path).to be_nil
      end
    end

    context "when scope is final is restricted by institution" do
      let(:scope) { 'final_restricted_institution' }

      it "returns 'table_bulk_actions/final_submission_restricted_or_witheld'" do
        expect(view.additional_bulk_actions_path).to eq 'admin/submissions/table_bulk_actions/final_submission_restricted_or_witheld'
      end
    end

    context "when scope is final restricted" do
      let(:scope) { 'final_withheld' }

      it "returns 'table_bulk_actions/final_submission_restricted_or_witheld'" do
        expect(view.additional_bulk_actions_path).to eq 'admin/submissions/table_bulk_actions/final_submission_restricted_or_witheld'
      end
    end
  end

  describe '#render_additional_selections?' do
    context "when scope is format review is incomplete" do
      let(:scope) { 'format_review_incomplete' }

      it "returns false" do
        expect(view).not_to be_render_additional_selections
      end
    end

    context "when scope is format review is submitted" do
      let(:scope) { 'format_review_submitted' }

      it "returns false" do
        expect(view).not_to be_render_additional_selections
      end
    end

    context "when scope is format review is completed" do
      let(:scope) { 'format_review_completed' }

      it "returns false" do
        expect(view).not_to be_render_additional_selections
      end
    end

    context "when scope is final submission is incomplete" do
      let(:scope) { 'final_submission_incomplete' }

      it "returns false" do
        expect(view).not_to be_render_additional_selections
      end
    end

    context "when scope is final submission is submitted" do
      let(:scope) { 'final_submission_submitted' }

      it "returns false" do
        expect(view).not_to be_render_additional_selections
      end
    end

    context "when scope is final submission is approved" do
      let(:scope) { 'final_submission_approved' }

      it "returns false" do
        expect(view).not_to be_render_additional_selections
      end
    end

    context "when scope is final submission is on hold" do
      let(:scope) { 'final_submission_on_hold' }

      it "returns false" do
        expect(view).not_to be_render_additional_selections
      end
    end

    context "when scope is released for publication" do
      let(:scope) { 'released_for_publication' }

      it "returns false" do
        expect(view).not_to be_render_additional_selections
      end
    end

    context "when scope is final is restricted by institution" do
      let(:scope) { 'final_restricted_institution' }

      it "returns true" do
        expect(view.render_additional_selections?).to be true
      end
    end

    context "when scope is final restricted" do
      let(:scope) { 'final_withheld' }

      it "returns true" do
        expect(view.render_additional_selections?).to be true
      end
    end
  end

  describe '#additional_selections_path' do
    context "when scope is format review is incomplete" do
      let(:scope) { 'format_review_incomplete' }

      it "returns nil" do
        expect(view.additional_selections_path).to be_nil
      end
    end

    context "when scope is format review is submitted" do
      let(:scope) { 'format_review_submitted' }

      it "returns nil" do
        expect(view.additional_selections_path).to be_nil
      end
    end

    context "when scope is format review is completed" do
      let(:scope) { 'format_review_completed' }

      it "returns nil" do
        expect(view.additional_selections_path).to be_nil
      end
    end

    context "when scope is final submission is incomplete" do
      let(:scope) { 'final_submission_incomplete' }

      it "returns nil" do
        expect(view.additional_selections_path).to be_nil
      end
    end

    context "when scope is final submission is submitted" do
      let(:scope) { 'final_submission_submitted' }

      it "returns nil" do
        expect(view.additional_selections_path).to be_nil
      end
    end

    context "when scope is final submission is approved" do
      let(:scope) { 'final_submission_approved' }

      it "returns nil" do
        expect(view.additional_selections_path).to be_nil
      end
    end

    context "when scope is final submission is on hold" do
      let(:scope) { 'final_submission_on_hold' }

      it "returns nil" do
        expect(view.additional_selections_path).to be_nil
      end
    end

    context "when scope is released for publication" do
      let(:scope) { 'released_for_publication' }

      it "returns nil" do
        expect(view.additional_selections_path).to be_nil
      end
    end

    context "when scope is final is restricted by institution" do
      let(:scope) { 'final_restricted_institution' }

      it "returns 'table_selections/final_submission_restricted_or_witheld'" do
        expect(view.additional_selections_path).to eq 'admin/submissions/table_selections/final_submission_restricted_or_witheld'
      end
    end

    context "when scope is final restricted" do
      let(:scope) { 'final_withheld' }

      it "returns 'table_selections/final_submission_restricted_or_witheld'" do
        expect(view.additional_selections_path).to eq 'admin/submissions/table_selections/final_submission_restricted_or_witheld'
      end
    end
  end

  describe '#render_delete_button?' do
    context "when scope is format review is incomplete" do
      let(:scope) { 'format_review_incomplete' }

      it "returns true" do
        expect(view).to be_render_delete_button
        expect(view.delete_button_partial).to eq('admin/submissions/table_bulk_actions/delete_button')
      end
    end

    context "when scope is format review is submitted" do
      let(:scope) { 'format_review_submitted' }

      it "returns true" do
        expect(view).to be_render_delete_button
        expect(view.delete_button_partial).to eq('admin/submissions/table_bulk_actions/delete_button')
      end
    end

    context "when scope is format review is completed" do
      let(:scope) { 'format_review_completed' }

      it "returns false" do
        expect(view).to be_render_delete_button
        expect(view.delete_button_partial).to eq('admin/submissions/table_bulk_actions/delete_button')
      end
    end

    context "when scope is final submission is incomplete" do
      let(:scope) { 'final_submission_incomplete' }

      it "returns false" do
        expect(view).to be_render_delete_button
        expect(view.delete_button_partial).to eq('admin/submissions/table_bulk_actions/delete_button')
      end
    end

    context "when scope is final submission is submitted" do
      let(:scope) { 'final_submission_submitted' }

      it "returns false" do
        expect(view).to be_render_delete_button
        expect(view.delete_button_partial).to eq('admin/submissions/table_bulk_actions/delete_button')
      end
    end

    context "when scope is final submission is approved" do
      let(:scope) { 'final_submission_approved' }

      it "returns false" do
        expect(view).to be_render_delete_button
        expect(view.delete_button_partial).to eq('admin/submissions/table_bulk_actions/delete_button')
      end
    end

    context "when scope is final submission is on hold" do
      let(:scope) { 'final_submission_on_hold' }

      it "returns false" do
        expect(view).to be_render_delete_button
        expect(view.delete_button_partial).to eq('admin/submissions/table_bulk_actions/delete_button')
      end
    end

    context "when scope is released for publication" do
      let(:scope) { 'released_for_publication' }

      it "returns false" do
        expect(view).not_to be_render_delete_button
        expect(view.delete_button_partial).to eq('admin/submissions/table_bulk_actions/delete_button')
      end
    end

    context "when scope is final is restricted by institution" do
      let(:scope) { 'final_restricted_institution' }

      it "returns true" do
        expect(view).not_to be_render_delete_button
        expect(view.delete_button_partial).to eq('admin/submissions/table_bulk_actions/delete_button')
      end
    end

    context "when scope is final restricted" do
      let(:scope) { 'final_withheld' }

      it "returns true" do
        expect(view).not_to be_render_delete_button
        expect(view.delete_button_partial).to eq('admin/submissions/table_bulk_actions/delete_button')
      end
    end
  end

  describe "#render_select_visible_buttons?" do
    context "when scope is format review is incomplete" do
      let(:scope) { 'format_review_incomplete' }

      it "returns true" do
        expect(view).to be_render_select_visible_buttons
        expect(view.select_visible_buttons_partial).to eq('admin/submissions/table_bulk_actions/select_visible_buttons')
      end
    end

    context "when scope is format review is submitted" do
      let(:scope) { 'format_review_submitted' }

      it "returns true" do
        expect(view).to be_render_select_visible_buttons
        expect(view.select_visible_buttons_partial).to eq('admin/submissions/table_bulk_actions/select_visible_buttons')
      end
    end

    context "when scope is format review is completed" do
      let(:scope) { 'format_review_completed' }

      it "returns false" do
        expect(view).to be_render_select_visible_buttons
        expect(view.select_visible_buttons_partial).to eq('admin/submissions/table_bulk_actions/select_visible_buttons')
      end
    end

    context "when scope is final submission is incomplete" do
      let(:scope) { 'final_submission_incomplete' }

      it "returns false" do
        expect(view).to be_render_select_visible_buttons
        expect(view.select_visible_buttons_partial).to eq('admin/submissions/table_bulk_actions/select_visible_buttons')
      end
    end

    context "when scope is final submission is submitted" do
      let(:scope) { 'final_submission_submitted' }

      it "returns false" do
        expect(view).to be_render_select_visible_buttons
        expect(view.select_visible_buttons_partial).to eq('admin/submissions/table_bulk_actions/select_visible_buttons')
      end
    end

    context "when scope is final submission is approved" do
      let(:scope) { 'final_submission_approved' }

      it "returns false" do
        expect(view).to be_render_select_visible_buttons
        expect(view.select_visible_buttons_partial).to eq('admin/submissions/table_bulk_actions/select_visible_buttons')
      end
    end

    context "when scope is final submission is on hold" do
      let(:scope) { 'final_submission_on_hold' }

      it "returns false" do
        expect(view).to be_render_select_visible_buttons
        expect(view.select_visible_buttons_partial).to eq('admin/submissions/table_bulk_actions/select_visible_buttons')
      end
    end

    context "when scope is released for publication" do
      let(:scope) { 'released_for_publication' }

      it "returns false" do
        expect(view).not_to be_render_select_visible_buttons
        expect(view.select_visible_buttons_partial).to eq('admin/submissions/table_bulk_actions/select_visible_buttons')
      end
    end

    context "when scope is final is restricted by institution" do
      let(:scope) { 'final_restricted_institution' }

      it "returns true" do
        expect(view).to be_render_select_visible_buttons
        expect(view.select_visible_buttons_partial).to eq('admin/submissions/table_bulk_actions/select_visible_buttons')
      end
    end

    context "when scope is final restricted" do
      let(:scope) { 'final_withheld' }

      it "returns true" do
        expect(view).to be_render_select_visible_buttons
        expect(view.select_visible_buttons_partial).to eq('admin/submissions/table_bulk_actions/select_visible_buttons')
      end
    end
  end
end
