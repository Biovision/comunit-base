# frozen_string_literal: true

# Document for trade union
# 
# Attributes:
#   attachment [SimpleFileUploader]
#   created_at [DateTime]
#   data [jsonb]
#   name [string]
#   priority [integer]
#   trade_union_id [TradeUnion]
#   updated_at [DateTime]
#   uuid [uuid]
class TradeUnionDocument < ApplicationRecord
  include BelongsToSite
  include HasUuid
  include NestedPriority

  mount_uploader :attachment, SimpleFileUploader

  belongs_to :trade_union

  scope :list_for_visitors, -> { ordered_by_priority }
  scope :list_for_administration, -> { ordered_by_priority }

  # @param [TradeUnionDocument] entity
  def self.siblings(entity)
    where(trade_union_id: entity&.trade_union_id)
  end

  def self.entity_parameters
    %i[attachment name priority]
  end

  def self.creation_parameters
    entity_parameters + %i[trade_union_id]
  end
end
