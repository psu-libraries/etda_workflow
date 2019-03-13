# frozen_string_literal: true

class Admin::ApprovalConfigurationsController < AdminController
  def index
  end

  def edit
    @approval_configuration = DegreeType.find(params[:id]).approval_configuration
  end

  def update
    @approval_configuration = DegreeType.find(params[:id]).approval_configuration
    @approval_configuration.attributes = approval_configuration_params
    @approval_configuration.save!
    redirect_to admin_approval_configurations_path
    flash[:notice] = 'Approval Configuration successfully updated'
  rescue ActiveRecord::RecordInvalid => e
    flash[:error] = e.message
    render :edit
  end

  private

  def approval_configuration_params
    approval_configuration_params_permitted = [:approval_deadline_on,
                               :rejections_permitted,
                               :email_admins,
                               :email_authors]

    params.require(:approval_configuration).permit(approval_configuration_params_permitted)
  end
end
