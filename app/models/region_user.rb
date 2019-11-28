# frozen_string_literal: true

# Allowed region for user
#
# Attributes:
#   created_at [DateTime]
#   region_id [Region], optional
#   updated_at [DateTime]
#   user_id [User]
class RegionUser < ApplicationRecord
  include HasOwner

  belongs_to :region, optional: true
  belongs_to :user

  validates_uniqueness_of :region_id, scope: :user_id

  scope :recent, -> { order('id desc') }

  # @param [User] user
  def self.allowed_region_ids(user)
    region_ids = owned_by(user).pluck(:region_id)

    return [] if region_ids.empty?

    Region.where(id: region_ids).pluck(:children_cache).flatten.uniq
  end
end
