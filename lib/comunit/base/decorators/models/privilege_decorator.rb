Privilege.class_eval do
  include Toggleable

  toggleable :regional

  def self.entity_parameters
    %i(regional name slug priority description)
  end

  # @param [User] user
  # @param [Region] region
  def has_user?(user, region = nil)
    criteria          = { user: user }
    criteria[:region] = region if regional?
    user_privileges.exists?(criteria) || user&.super_user?
  end

  # @param [User] user
  # @param [Region] region
  def grant(user, region)
    criteria          = { privilege: self, user: user }
    criteria[:region] = region if regional?
    UserPrivilege.create(criteria) unless UserPrivilege.exists?(criteria)
  end

  # @param [User] user
  # @param [Region] region
  def revoke(user, region)
    criteria          = { privilege: self, user: user }
    criteria[:region] = region if regional?
    UserPrivilege.where(criteria).destroy_all
  end
end
