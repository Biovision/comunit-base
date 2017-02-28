class UserGroup < ApplicationRecord
  belongs_to :user
  belongs_to :group, counter_cache: :users_count

  validates_uniqueness_of :user_id, scope: [:group_id]
end
