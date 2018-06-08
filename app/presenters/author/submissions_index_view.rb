class Author::SubmissionsIndexView
  attr_reader :submissions

  def initialize(author)
    @author = author
    # @author.refresh(author.access_id, author.psu_idn)
    @submissions = @author.unpublished_submissions
    InboundLionPathRecord.transition_to_lionpath(@submissions) if InboundLionPathRecord.active?
  end

  def partial_name
    if update_contact_information?
      'confirm_contact_information_instructions'
    elsif @author.unpublished_submissions.count.positive?
      'submissions'
    else
      'no_submissions'
    end
  end

  def no_submissions_message
    return "" unless @author.submissions.released_for_publication.count.zero?
    "You don't have any submissions yet."
  end

  def published_submissions_message
    return '' unless @author.submissions.released_for_publication.count.positive?
    "<p>Your published submissions may be viewed at: #{published_submissions_link}</p>"
  end

  def contact_information_path
    Rails.application.routes.url_helpers.edit_author_author_path(@author)
  end

  def update_contact_information?
    if current_partner.graduate?
      @author.opt_out_default? || @author.alternate_email_address.nil?
    else
      @author.alternate_email_address.nil?
    end
  end

  def published_submissions_link
    "<a href='/author/published_submissions'>My Published Submissions</a>"
  end
end
