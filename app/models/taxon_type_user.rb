# frozen_string_literal: true

# Taxon type available to user
#
# Attributes:
#   taxon_type_id [TaxonType]
#   user_id [User]
class TaxonTypeUser < ApplicationRecord
  include HasOwner

  belongs_to :taxon_type
  belongs_to :user

  validates_uniqueness_of :taxon_type_id, scope: :user_id
end
