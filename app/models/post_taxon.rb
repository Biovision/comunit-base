# frozen_string_literal: true

# Link between post and post taxon
#
# Attributes:
#   post_id [Post]
#   taxon_id [Taxon]
class PostTaxon < ApplicationRecord
  belongs_to :post
  belongs_to :taxon, counter_cache: :posts_count

  validates_uniqueness_of :taxon_id, scope: :post_id
end
