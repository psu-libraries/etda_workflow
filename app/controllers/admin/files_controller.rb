class Admin::FilesController < FilesController
  private

    def current_ability
      @current_ability ||= AdminAbility.new(current_admin)
    end
end
