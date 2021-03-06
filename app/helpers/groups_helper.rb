module GroupsHelper
  # @param [Group] entity
  def admin_group_link(entity)
    link_to(entity.name, admin_group_path(id: entity.id))
  end

  # @param [Team] entity
  def admin_team_link(entity)
    link_to(entity.name, admin_team_path(id: entity.id))
  end
end
