# frozen_string_literal: true

# User in trade union
#
# Attributes:
#   created_at [DateTime]
#   data [jsonb]
#   trade_union_id [TradeUnion]
#   updated_at [DateTime]
#   user_id [User]
class TradeUnionUser < ApplicationRecord
  include HasOwner
  include BelongsToSite

  belongs_to :trade_union, counter_cache: :user_count
  belongs_to :user

  validates_presence_of :user_id, scope: :trade_union_id
end
