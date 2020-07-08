# frozen_string_literal: true

# Featured post
class FeaturedPost < ApplicationRecord
  include FlatPriority

  belongs_to :post

  validates_uniqueness_of :post_id

  scope :list_for_administration, -> { ordered_by_priority }
end
