# frozen_string_literal: true

class Author::AuthorsController < AuthorController
  class NotAuthorizedToEdit < StandardError; end
  before_action :verify_author, except: :technical_tips

  def edit
    # @author = Author.find(params[:id])
    render :edit
  rescue Author::NotAuthorizedToEdit
    redirect_to '/401'
  rescue ActiveRecord::RecordNotFound
    redirect_to author_root_path
    flash[:alert] = 'Unable to locate author record'
  end

  def update
    if @author.psu_idn.blank?
      @author.psu_idn = Author.new.psu_id_number(@author.access_id)
      @author.save
    end
    @author.update!(author_params)
    redirect_to author_root_path
    flash[:notice] = 'Contact information updated successfully'
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.record.errors.values.join(" ")
    render :edit
  rescue Author::NotAuthorizedToEdit
    redirect_to '/401'
  rescue ActiveRecord::RecordNotFound
    redirect_to author_root_path
    flash[:alert] = 'Unable to locate author record'
  end

  def technical_tips
    render "technical_tips"
  end

  private

  def verify_author
    @author = Author.find(params[:id])
    redirect_to '/404' if @author.nil? || current_author.nil?
    redirect_to '/401' unless @author_ability.can? :edit, @author
  end

  def author_params
    author_params_list = [:access_id,
                          :first_name,
                          :middle_name,
                          :last_name,
                          :alternate_email_address,
                          :psu_email_address,
                          :phone_number,
                          :is_alternate_email_public,
                          :address_1,
                          :address_2,
                          :city,
                          :state,
                          :zip,
                          :country]

    params.require(:author).permit(author_params_list)
  end
end
