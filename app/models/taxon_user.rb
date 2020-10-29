# frozen_string_literal: true

# Taxon available to user
#
# Attributes:
#   taxon_id [Taxon]
#   user_id [User]
class TaxonUser < ApplicationRecord
  include HasOwner

  belongs_to :taxon
  belongs_to :user

  validates_uniqueness_of :taxon_id, scope: :user_id
end
