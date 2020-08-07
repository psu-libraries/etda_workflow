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
    @author.attributes = author_params
    @author.save(validate: false)
    redirect_to admin_authors_path
    flash[:notice] = 'Author successfully updated'
  rescue ActiveRecord::RecordInvalid => e
    flash[:error] = e.record.errors.values.join(" ")
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

    params.require(:author).permit(author_params_permitted)
  end
end
