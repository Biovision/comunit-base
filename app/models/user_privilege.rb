class UserPrivilege < ApplicationRecord
  include Biovision::UserPrivilege

  belongs_to :user
  belongs_to :privilege, counter_cache: :users_count
  belongs_to :region, optional: true

  validates_uniqueness_of :privilege_id, scope: [:user_id, :region_id]

  # @param [User] user
  # @param [String|Symbol] privilege_name
  # @param [Region] region
  def self.user_has_privilege?(user, privilege_name, region = nil)
    return false if user.nil?
    return true if user.super_user?
    privilege = Privilege.find_by(slug: privilege_name)
    privilege&.has_user?(user, region)
  end
end
