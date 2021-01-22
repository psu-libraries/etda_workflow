# frozen_string_literal: true

class ApproverController < ApplicationController
  before_action :approver_auth

  layout 'approver'

  protected

  def approver_auth
    authenticate_approver! unless approver_signed_in?
    @approver = current_approver
  end

  def approver_ability
    @approver_ability ||= ApproverAbility.new(@approver, params[:id])
  end
end
