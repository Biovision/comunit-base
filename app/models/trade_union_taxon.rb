# frozen_string_literal: true

# Taxon in trade union
#
# Attributes:
#   taxon_id [Taxon]
#   trade_union_id [TradeUnion]
class TradeUnionTaxon < ApplicationRecord
  belongs_to :trade_union
  belongs_to :taxon

  validates_uniqueness_of :taxon_id, scope: :trade_union_id
end
