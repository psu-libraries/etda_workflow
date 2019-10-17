# frozen_string_literal: true

class Admin::ApprovalConfigurationsController < AdminController
  def index
  end

  def edit
    @approval_configuration = ApprovalConfiguration.find(params[:id])
  end

  def update
    @approval_configuration = ApprovalConfiguration.find(params[:id])
    @approval_configuration.attributes = approval_configuration_params
    @approval_configuration.save!
    redirect_to admin_approval_configurations_path
    flash[:notice] = 'Approval Configuration successfully updated'
  rescue ActiveRecord::RecordInvalid => e
    flash[:error] = e.record.errors.values.join(" ")
    render :edit
  end

  private

  def approval_configuration_params
    approval_configuration_params_permitted = [:approval_deadline_on, :email_admins, :email_authors, :configuration_threshold, :use_percentage, :head_of_program_is_approving]

    params.require(:approval_configuration).permit(approval_configuration_params_permitted)
  end
end
