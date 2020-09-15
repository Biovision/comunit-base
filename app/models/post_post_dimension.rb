# frozen_string_literal: true

# Link between post and post dimension
#
# Attributes:
#   post_dimension_id [PostDimension]
#   post_id [Post]
class PostPostDimension < ApplicationRecord
  belongs_to :post
  belongs_to :post_dimension, counter_cache: :posts_count

  validates_uniqueness_of :post_dimension_id, scope: :post_id
end
