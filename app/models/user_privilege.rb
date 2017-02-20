class UserPrivilege < ApplicationRecord
  belongs_to :user
  belongs_to :privilege, counter_cache: :users_count
  belongs_to :region, optional: true

  validates_uniqueness_of :privilege_id, scope: [:user_id, :region_id]

  # @param [User] user
  # @param [String|Symbol] privilege_name
  # @param [Region] region
  def self.user_has_privilege?(user, privilege_name, region = nil)
    privilege = Privilege.find_by(slug: privilege_name)
    privilege&.has_user?(user, region)
  end

  # @param [User] user
  def self.user_has_any_privilege?(user)
    exists?(user: user) || user&.super_user?
  end

  # @param [User] user
  # @param [Symbol] group_name
  def self.user_has_privilege_group?(user, group_name)
    privilege_ids = Privilege.ids_in_privilege_group(group_name)
    exists?(user: user, privilege_id: privilege_ids) || user&.super_user?
  end
end
