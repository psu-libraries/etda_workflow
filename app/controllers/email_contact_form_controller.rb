# frozen_string_literal: true

class EmailContactFormController < ApplicationController
  before_action :set_author

  def new
    @email_contact_form = EmailContactForm.new(full_name: @email_contact_author.full_name, email: @email_contact_author.psu_email_address)
  end

  def create
    @email_contact_form = EmailContactForm.new
    @email_contact_form.full_name = request[:email_contact_form][:full_name].html_safe
    @email_contact_form.email = request[:email_contact_form][:email].html_safe
    @email_contact_form.desc = request[:email_contact_form][:desc].html_safe
    @email_contact_form.message = request[:email_contact_form][:message].html_safe
    if @email_contact_form.deliver
      flash[:notice] = 'Thank you for your message!'
      redirect_to root_path
    else
      flash[:alert] = 'Cannot send message.'
      render :new
    end
  end

  private

  def set_author
    redirect_to Rails.application.routes.url_helpers.login_author_path if current_author.nil?
    @email_contact_author = Author.new
    @email_contact_author = current_author
  end
end
