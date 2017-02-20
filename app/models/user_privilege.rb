class UserPrivilege < ApplicationRecord
  belongs_to :user
  belongs_to :privilege, counter_cache: :users_count
  belongs_to :region, optional: true

  validates_uniqueness_of :privilege_id, scope: [:user_id, :region_id]
end
