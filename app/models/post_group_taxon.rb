# frozen_string_literal: true

# Taxon in post group
#
# Attributes:
#   post_group_id [PostGroup]
#   priority [Integer]
#   taxon_id [Taxon]
class PostGroupTaxon < ApplicationRecord
  include NestedPriority

  belongs_to :post_group
  belongs_to :taxon

  validates_uniqueness_of :taxon_id, scope: :post_group_id

  scope :list_for_administration, -> { ordered_by_priority }

  # @param [PostGroupTaxon] entity
  def self.siblings(entity)
    where(post_group_id: entity.post_group_id)
  end

  # @param [String|PostGroup] slug
  def self.[](slug)
    post_group = slug.is_a?(PostGroup) ? slug : PostGroup[slug]
    clause = {
      post_group: post_group,
      taxa: { visible: true }
    }

    includes(:taxon).where(clause).order('post_group_taxa.priority asc').map(&:taxon).compact
  end
end
