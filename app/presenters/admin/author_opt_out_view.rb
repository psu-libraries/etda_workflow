class Admin::AuthorOptOutView
  def author_email_list
    @authors = []
    Author.all.each do |a|
      next unless a.submissions.count.positive?

      author_info = email_contact_info(a)
      @authors << author_info.first unless author_info.nil?
    end
    @authors
  end

  def confidential_tag(author)
    ApplicationController.helpers.confidential_tag_helper(author)
  end

  private

  def email_contact_info(author)
    return nil unless author.submissions.last.status_behavior.released_for_publication?

    [id: author.id, last_name: author.last_name, first_name: author.first_name,
     year: author.submissions.last.year, alternate_email_address: author.alternate_email_address,
     confidential_alert_icon: confidential_tag(author)]
  end
end
