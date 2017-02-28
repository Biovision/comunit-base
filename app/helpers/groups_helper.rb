module GroupsHelper
  # @param [Group] entity
  def admin_group_link(entity)
    link_to(entity.name, admin_group_path(entity.id))
  end
end
