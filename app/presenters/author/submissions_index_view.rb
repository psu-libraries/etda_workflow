class Author::SubmissionsIndexView
  attr_reader :submissions

  def initialize(author)
    @author = author
    # @author.refresh(author.access_id, author.psu_idn)
    @submissions = @author.unpublished_submissions
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
    if current_partner.graduate?
      return "You don't have any submissions to complete.
              Please contact your program office to begin a submission."
    end

    "You don't have any submissions to complete."
  end

  def published_submissions_message
    return '' unless @author.submissions.released_for_publication.count.positive?

    "<p>Your published submissions may be viewed at: #{published_submissions_link}</p>"
  end

  def contact_information_path
    Rails.application.routes.url_helpers.edit_author_author_path(@author)
  end

  def update_contact_information?
    @author.alternate_email_address.blank? || (current_partner.graduate? && @author.address_1.blank?)
  end
end
