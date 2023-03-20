class EmailContactFormController < ApplicationController
  def new
    @email_contact_form = initialized_new_form
  end

  def create
    @email_contact_form = initialized_create_form(request)
    if @email_contact_form.deliver
      flash[:notice] = 'Thank you for your message!'
      redirect_to '/approver' if approver?
      redirect_to root_path unless approver?
    else
      flash[:alert] = 'Cannot send message.'
      render :new
    end
  end

  private

    def initialized_create_form(request)
      email_contact_form = EmailContactForm.new
      email_contact_form.full_name = request[:email_contact_form][:full_name].html_safe
      email_contact_form.email = request[:email_contact_form][:email].html_safe
      email_contact_form.psu_id = request[:email_contact_form][:psu_id].html_safe if author?
      email_contact_form.desc = request[:email_contact_form][:desc].html_safe
      email_contact_form.message = request[:email_contact_form][:message].html_safe
      email_contact_form.issue_type = request[:email_contact_form][:issue_type].html_safe
      email_contact_form
    end

    def initialized_new_form
      return new_author_form if author?

      return new_approver_form if approver?

      EmailContactForm.new
    end

    def new_author_form
      EmailContactForm.new(full_name: email_contact_user.full_name,
                           email: email_contact_user.psu_email_address,
                           psu_id: email_contact_user.psu_id)
    end

    def new_approver_form
      EmailContactForm.new(email: "#{email_contact_user.access_id}@psu.edu")
    end

    def email_contact_user
      approver? ? current_approver : current_author
    end

    def approver?
      session[:user_role] == 'approver'
    end

    def author?
      session[:user_role] == 'author'
    end
end
