# in models/admin_ability.rb
class AdminAbility
  include CanCan::Ability
  def initialize(admin)
    # super(admin)
    return unless !admin.blank? && (admin.administrator? || admin.site_administrator?)
    can [:read, :edit, :view, :administer], :all
  end
end
