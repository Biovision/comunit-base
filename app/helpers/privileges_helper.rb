module PrivilegesHelper
  # @param [Privilege] privilege
  def admin_privilege_link(privilege)
    link_to(privilege.name, admin_privilege_path(privilege.id))
  end
end
