class Admin::SubmissionsDashboardView
  def initialize(degree_type_param)
    @degree_type = DegreeType.find_by!(slug: degree_type_param)
  end

  def title
    @degree_type.name.pluralize
  end

  def filters
    [
      format_review_is_incomplete_filter,
      format_review_is_submitted_filter,
      format_review_is_completed_filter,
      final_submission_is_submitted_filter,
      final_submission_is_incomplete_filter,
      final_submission_is_approved_filter,
      released_for_publication_filter,
      final_is_restricted_institution_filter,
      final_is_withheld_filter
    ]
  end

  private

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

    def final_is_restricted_institution_filter
      # honors does not allow authors to restrict by institution
      submissions = Submission.joins(:degree).where('degrees.degree_type_id' => @degree_type.id).final_is_restricted_institution
      {
        id: 'final-restricted-institution',
        title: title_for('final_restricted_institution'),
        description: description_for('final_restricted_institution'),
        path:  submissions.empty? ? nil : "/admin/#{@degree_type.slug}/final_restricted_institution",
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
        path:  submissions.empty? ? nil : "/admin/#{@degree_type.slug}/final_withheld",
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
      I18n.t("#{current_partner.id}.admin_filters.#{index_view_scope}.title")
    end

    def description_for(index_view_scope)
      I18n.t("#{current_partner.id}.admin_filters.#{index_view_scope}.description")
    end
end
