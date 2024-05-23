class Admin::SubmissionsDashboardView
  def initialize(degree_type_param)
    @degree_type = DegreeType.find_by!(slug: degree_type_param)
  end

  def title
    @degree_type.name.pluralize
  end

  def filters
    standard_filters
  end

  private

    def standard_filters
      [
        format_review_is_incomplete_filter,
        format_review_is_submitted_filter,
        format_review_is_completed_filter,
        final_submission_is_pending_filter,
        committee_review_is_rejected_filter,
        final_submission_is_submitted_filter,
        final_submission_is_incomplete_filter,
        final_submission_is_approved_filter,
        final_submission_is_on_hold_filter,
        released_for_publication_filter,
        final_is_restricted_institution_filter,
        final_is_withheld_filter
      ]
    end

    def format_review_is_incomplete_filter
      submissions = Submission.joins(:degree).where('degrees.degree_type_id' => @degree_type.id).format_review_is_incomplete
      {
        id: 'format-review-incomplete',
        title: title_for('format_review_incomplete'),
        description: description_for('format_review_incomplete'),
        path: submissions.empty? ? nil : "/admin/#{@degree_type.slug}/format_review_incomplete",
        count: submissions.empty? ? nil : submissions.count.to_s
      }
    end

    def format_review_is_submitted_filter
      submissions = Submission.joins(:degree).where('degrees.degree_type_id' => @degree_type.id).format_review_is_submitted
      {
        id: 'format-review-submitted',
        title: title_for('format_review_submitted'),
        description: description_for('format_review_submitted'),
        path: submissions.empty? ? nil : "/admin/#{@degree_type.slug}/format_review_submitted",
        count: submissions.empty? ? nil : submissions.count.to_s
      }
    end

    def format_review_is_completed_filter
      submissions = Submission.joins(:degree).where('degrees.degree_type_id' => @degree_type.id).format_review_is_completed
      {
        id: 'format-review-completed',
        title: title_for('format_review_completed'),
        description: description_for('format_review_completed'),
        path: submissions.empty? ? nil : "/admin/#{@degree_type.slug}/format_review_completed",
        count: submissions.empty? ? nil : submissions.count.to_s
      }
    end

    def final_submission_is_submitted_filter
      submissions = Submission.joins(:degree).where('degrees.degree_type_id' => @degree_type.id).final_submission_is_submitted
      {
        id: 'final-submission-submitted',
        title: title_for('final_submission_submitted'),
        description: description_for('final_submission_submitted'),
        path: submissions.empty? ? nil : "/admin/#{@degree_type.slug}/final_submission_submitted",
        count: submissions.empty? ? nil : submissions.count.to_s
      }
    end

    def final_submission_is_incomplete_filter
      submissions = Submission.joins(:degree).where('degrees.degree_type_id' => @degree_type.id).final_submission_is_incomplete
      {
        id: 'final-submission-incomplete',
        title: title_for('final_submission_incomplete'),
        description: description_for('final_submission_incomplete'),
        path: submissions.empty? ? nil : "/admin/#{@degree_type.slug}/final_submission_incomplete",
        count: submissions.empty? ? nil : submissions.count.to_s
      }
    end

    def final_submission_is_pending_filter
      submissions = Submission.joins(:degree).where('degrees.degree_type_id' => @degree_type.id).final_submission_is_pending
      {
        id: 'final-submission-pending',
        title: title_for('final_submission_pending'),
        description: description_for('final_submission_pending'),
        path: submissions.empty? ? nil : "/admin/#{@degree_type.slug}/final_submission_pending",
        count: submissions.empty? ? nil : submissions.count.to_s
      }
    end

    def committee_review_is_rejected_filter
      submissions = Submission.joins(:degree).where('degrees.degree_type_id' => @degree_type.id).committee_review_is_rejected
      {
        id: 'committee-review-rejected',
        title: title_for('committee_review_rejected'),
        description: description_for('committee_review_rejected'),
        path: submissions.empty? ? nil : "/admin/#{@degree_type.slug}/committee_review_rejected",
        count: submissions.empty? ? nil : submissions.count.to_s
      }
    end

    def final_submission_is_approved_filter
      submissions = Submission.joins(:degree).where('degrees.degree_type_id' => @degree_type.id).final_submission_is_approved
      {
        id: 'final-submission-approved',
        title: title_for('final_submission_approved'),
        description: description_for('final_submission_approved'),
        path: submissions.empty? ? nil : "/admin/#{@degree_type.slug}/final_submission_approved",
        count: submissions.empty? ? nil : submissions.count.to_s
      }
    end

    def final_submission_is_on_hold_filter
      submissions = Submission.joins(:degree).where('degrees.degree_type_id' => @degree_type.id).final_submission_is_on_hold
      {
        id: 'final-submission-on-hold',
        title: title_for('final_submission_on_hold'),
        description: description_for('final_submission_on_hold'),
        path: submissions.empty? ? nil : "/admin/#{@degree_type.slug}/final_submission_on_hold",
        count: submissions.empty? ? nil : submissions.count.to_s
      }
    end

    def final_is_restricted_institution_filter
      # honors does not allow authors to restrict by institution
      submissions = Submission.joins(:degree).where('degrees.degree_type_id' => @degree_type.id).final_is_restricted_institution
      {
        id: 'final-restricted-institution',
        title: title_for('final_restricted_institution'),
        description: description_for('final_restricted_institution'),
        path: submissions.empty? ? nil : "/admin/#{@degree_type.slug}/final_restricted_institution",
        count: submissions.empty? ? nil : submissions.count.to_s,
        sub_count: submissions.empty? ? nil : submissions.ok_to_release.count.to_s
      }
    end

    def final_is_withheld_filter
      submissions = Submission.joins(:degree).where('degrees.degree_type_id' => @degree_type.id).final_is_withheld
      {
        id: 'final-withheld',
        title: title_for('final_withheld'),
        description: description_for('final_withheld'),
        path: submissions.empty? ? nil : "/admin/#{@degree_type.slug}/final_withheld",
        count: submissions.empty? ? nil : submissions.count.to_s,
        sub_count: submissions.empty? ? nil : submissions.ok_to_release.count.to_s
      }
    end

    def released_for_publication_filter
      submissions = Submission.joins(:degree).where('degrees.degree_type_id' => @degree_type.id).released_for_publication
      {
        id: 'released-for-publication',
        title: title_for('released_for_publication'),
        description: description_for('released_for_publication'),
        path: submissions.empty? ? nil : "/admin/#{@degree_type.slug}/released_for_publication",
        count: submissions.empty? ? nil : submissions.count.to_s
      }
    end

    def title_for(index_view_scope)
      thesis_title = I18n.t("#{current_partner.id}.admin_filters.#{index_view_scope}.thesis_title")
      if @degree_type.slug == 'master_thesis' && !thesis_title.match?(/Translation missing/)
        thesis_title
      else
        I18n.t("#{current_partner.id}.admin_filters.#{index_view_scope}.title")
      end
    end

    def description_for(index_view_scope)
      thesis_description = I18n.t("#{current_partner.id}.admin_filters.#{index_view_scope}.thesis_description")
      if @degree_type.slug == 'master_thesis' && !thesis_description.match?(/Translation missing/)
        thesis_description
      else
        I18n.t("#{current_partner.id}.admin_filters.#{index_view_scope}.description")
      end
    end
end
