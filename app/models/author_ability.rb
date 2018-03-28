class AuthorAbility
  include CanCan::Ability
  def initialize(author, _file, _submission)
    return if author.blank?
    can [:read, :edit, :view, :update], Author, id: author.id
    can [:read, :edit, :view, :update, :destroy], Submission, author_id: author.id
    can [:read, :upload, :edit, :view], FormatReviewFile, submission: { author_id: author.id }
    can [:read, :upload, :edit, :view], FinalSubmissionFile, submission: { author_id: author.id }
  end
end
