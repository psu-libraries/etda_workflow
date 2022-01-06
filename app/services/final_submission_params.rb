module FinalSubmissionParams
  def self.call(params)
    params.require(:submission).permit(
      :semester,
      :author_submitted_semester,
      :year,
      :author_submitted_year,
      :author_id,
      :program_id,
      :degree_id,
      :title,
      :allow_all_caps_in_title,
      :format_review_notes,
      :admin_notes,
      :final_submission_notes,
      :defended_at,
      :abstract,
      :access_level,
      :is_printed,
      :has_agreed_to_terms,
      :has_agreed_to_publication_release,
      :restricted_notes,
      :federal_funding,
      :proquest_agreement,
      committee_members_attributes: [:id, :committee_role_id, :name, :email, :status, :notes, :is_required,
                                     :is_voting, :federal_funding_used, :_destroy],
      format_review_files_attributes: [:asset, :asset_cache, :id, :_destroy],
      final_submission_files_attributes: [:asset, :asset_cache, :id, :_destroy],
      keywords_attributes: [:word, :id, :_destroy],
      invention_disclosures_attributes: [:id, :submission_id, :id_number, :_destroy]
    )
  end
end
