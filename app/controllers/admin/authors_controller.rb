class Admin::AuthorsController < AdminController
  def index
    @authors = Author.all
  end

  def edit
    @author = Author.find(params[:id])
    @view = Admin::AuthorView.new(@author)
  end

  def update
    @author = Author.find(params[:id])
    @view = Admin::AuthorView.new(@author)
    outbound_lionpath_record = OutboundLionPathRecord.new(submission: @author.submissions.last, original_alternate_email: @author.alternate_email_address)
    @author.attributes = author_params
    @author.save(validate: false)
    outbound_lionpath_record.report_email_change unless @author.submissions.empty?
    redirect_to admin_authors_path
    flash[:notice] = 'Author successfully updated'
  rescue ActiveRecord::RecordInvalid => e
    flash[:error] = e.message
    render :edit
  end

  def email_contact_list
  end

  private

  def author_params
    author_params_permitted = [:access_id,
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

    author_params_permitted.merge(:inbound_lion_path_record_attributes[:lion_path_degree_code, :id, :author_id, :current_record]) if InboundLionPathRecord.active?

    params.require(:author).permit(author_params_permitted)
  end
end
