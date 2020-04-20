# frozen_string_literal: true

# Link between deed and deed category
#
# Attributes:
#   created_at [DateTime]
#   deed_category_id [DeedCategory]
#   deed_id [Deed]
#   updated_at [DateTime]
class DeedDeedCategory < ApplicationRecord
  belongs_to :deed
  belongs_to :deed_category, counter_cache: :deeds_count

  validates_uniqueness_of :deed_category_id, scope: :deed_id
end
