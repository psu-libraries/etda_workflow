class FileDownloadAbility
  include CanCan::Ability

  def initialize(author)
    author ||= Author.new
    # if author.admin?
    #   can :read, :all
    # else
    can :read, FinalSubmissionFile, submission: { author_id: author.id }
    can :read, FormatReviewFile, submission: { author_id: author.id }
    # anyone can download open_access file
    can :read, FinalSubmissionFile, submission: { access_level_key: 'open_access' }
    # only logged in users can read restricted files
    # unless author.id.blank?
    can :read, FinalSubmissionFile, submission: { access_level_key: 'restricted_to_institution', status: 'released for publication' }
    # end
    # end
  end
end
