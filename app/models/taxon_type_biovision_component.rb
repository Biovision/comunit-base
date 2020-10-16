# frozen_string_literal: true

# Taxon type for component
#
# Attributes:
#   biovision_component_id [BiovisionComponent]
#   taxon_type_id [TaxonType]
class TaxonTypeBiovisionComponent < ApplicationRecord
  belongs_to :biovision_component
  belongs_to :taxon_type

  validates_uniqueness_of :taxon_type_id, scope: :biovision_component_id
end
