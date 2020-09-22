# frozen_string_literal: true

# Taxon available to user
#
# Attributes:
#   taxon_id [References]
#   user_id [References]
class TaxonUser < ApplicationRecord
  include HasOwner

  belongs_to :taxon
  belongs_to :user

  validates_uniqueness_of :taxon_id, scope: :user_id
end
