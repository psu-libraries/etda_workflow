# frozen_string_literal: true

class ContactFormController < ApplicationController
  before_action :set_author
  def new
    @contact_author = current_author
    @contact_form = ContactForm.new(full_name: @contact_author.full_name, email: @contact_author.psu_email_address)
  end

  def create
    @contact_form = ContactForm.new
    @contact_form.full_name = request[:contact_form][:full_name].html_safe
    @contact_form.email = request[:contact_form][:email].html_safe
    @contact_form.desc = request[:contact_form][:desc].html_safe
    @contact_form.message = request[:contact_form][:message].html_safe
    if @contact_form.deliver
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
  end
end
