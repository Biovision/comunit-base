class RegionManager
  PRIVILEGES = %w(head chief_editor deputy_chief_editor reporter civic_reporter)

  attr_accessor :user

  # @param [User] user
  def initialize(user)
    @user = user
  end

  # @param [Integer] parent_id
  def for_tree(parent_id)
    if filter?
      filtered_tree(parent_id)
    else
      Region.visible.for_tree(nil, parent_id)
    end
  end

  def filtered_tree(parent_id)
    if parent_id.to_i < 1
      available_regions.ordered_by_name
    else
      Region.where(id: available_region_ids).visible.for_tree(nil, parent_id)
    end
  end

  def regional_privilege_ids
    @regional_privilege_ids ||= prepare_regional_privilege_ids
  end

  def available_regions
    criteria = { user: @user, privilege_id: regional_privilege_ids }
    Region.where(id: UserPrivilege.where(criteria).pluck(:region_id))
  end

  def available_region_ids
    available_regions.map(&:subbranch_ids).flatten.compact.uniq
  end

  # Нужно ли ограничивать список доступных регионов для текущего пользователя
  def filter?
    return false if @user.super_user?

    selection     = UserPrivilege.owned_by(@user)
    privilege_ids = Privilege.where(slug: PRIVILEGES).pluck(:id)
    if selection.where(privilege_id: privilege_ids).exists?
      false
    else
      selection.where(privilege_id: regional_privilege_ids).exists?
    end
  end

  private

  def prepare_regional_privilege_ids
    slugs = PRIVILEGES.map { |slug| "regional_#{slug}" }
    Privilege.where(regional: true, slug: slugs).pluck(:id)
  end
end
