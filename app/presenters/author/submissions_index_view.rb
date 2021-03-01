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
    return "You currently do not have any submissions to complete.  Start a new submission by completing your program information in <a target='_blank' href='https://lionpath.psu.edu'>LionPATH</a>. Your changes will be reflected here after the next update.  Updates run daily at 3AM ET." unless @author.submissions.released_for_publication.count.zero?

    return "You don't have any submissions yet.  Start your submission by completing your program information in <a target='_blank' href='https://lionpath.psu.edu'>LionPATH</a>. Your changes will be reflected here after the next update.  Updates run daily at 3AM ET." if current_partner.graduate?

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
    @author.alternate_email_address.nil?
  end
end
