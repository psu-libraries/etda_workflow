class Author::SubmissionsIndexView
  attr_reader :submissions

  def initialize(author)
    @author = author
    # @author.refresh(author.access_id, author.psu_idn)
    @submissions = @author.submissions.order(created_at: :desc)
    InboundLionPathRecord.transition_to_lionpath(@submissions) if InboundLionPathRecord.active?
  end

  def partial_name
    if new_author?
      'confirm_contact_information_instructions'
    elsif author_has_submissions?
      'submissions'
    else
      'no_submissions'
    end
  end

  def contact_information_path
    Rails.application.routes.url_helpers.edit_author_author_path(@author)
  end

  def new_author?
    @author.alternate_email_address.nil?
  end

  def author_has_submissions?
    @author.submissions.any?
  end
end
