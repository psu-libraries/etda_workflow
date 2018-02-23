# frozen_string_literal: true

class Author::AuthorsController < AuthorController
  def edit
    @author = Author.find(params[:id])
  rescue Author::NotAuthorizedToEdit
    redirect_to root_path
    flash[:error] = 'You are not authorized to edit that page'
  end

  def update
    @author = Author.find(params[:id])
    outbound_lionpath_record = OutboundLionPathRecord.new(submission: @author.submissions.last, original_alternate_email: @author.alternate_email_address)
    if params[:author][:inbound_lion_path_record]
      @author.inbound_lion_path_record.lion_path_degree_code = params[:author][:inbound_lion_path_record][:lion_path_degree_code]
      @author.inbound_lion_path_record.save
    end
    if @author.psu_idn.blank?
      @author.psu_idn = Author.new.psu_id_number(@author.access_id)
      @author.save
    end

    @author.update_attributes!(author_params)
    outbound_lionpath_record.report_email_change unless @author.submissions.empty?
    redirect_to author_root_path
    flash[:notice] = 'Contact information updated successfully'
  rescue Author::NotAuthorizedToEdit
    redirect_to root_path
    flash[:notice] = 'You are not authorized to edit that page'
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.message
    render :edit
  end

  def technical_tips
    render "technical_tips"
  end

  private

  def current_ability(author, record_id)
    @current_ability ||= AuthorAbility.new(author, record_id)
  end

  def author_params
    params.require(:author).permit(:access_id,
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
                                   :country)
  end
end
