@authors_emails = Admin::AuthorOptOutView.new.author_email_list

json.data @authors_emails, partial: 'authors_contact', as: :author_emails
