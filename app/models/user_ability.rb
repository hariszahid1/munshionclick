class UserAbility < ApplicationRecord

  establish_connection "#{Rails.env}".to_sym

  belongs_to :user, optional: true

  include RoleModel

  # Declare the valid roles. Do not change the order if you add more roles later, always append them
  # at the end! To remove roles, don't forget to re-assign all roles as they're position dependent.
  roles :view_status

  def view_status?
    has_role?(:view_status)
  end

  def abilityChecked?(u_role)
    if send(u_role.to_s+"?")
      "checked"
    end
  end
end
