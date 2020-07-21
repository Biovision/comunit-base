# frozen_string_literal: true

# Allowed post category for user
#
# Attributes:
#   created_at [DateTime]
#   post_category_id [PostCategory]
#   updated_at [DateTime]
#   user_id [User]
class PostCategoryUser < ApplicationRecord
  include HasOwner

  belongs_to :user
  belongs_to :post_category

  validates_uniqueness_of :post_category_id, scope: :user_id
end
