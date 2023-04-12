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
    author_attrs = author_params.merge(admin_edited_at: DateTime.now)
    @author.attributes = author_attrs
    @author.save(validate: false)
    # Update each submissions' updated_at timestamp so Solr detects an update
    @author.submissions.each { |s| s.update updated_at: DateTime.now }
    redirect_to admin_authors_path
    flash[:notice] = 'Author successfully updated'
  rescue ActiveRecord::RecordInvalid => e
    flash[:error] = e.record.errors.collect(&:message).join(" ")
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
