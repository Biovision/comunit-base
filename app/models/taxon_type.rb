# frozen_string_literal: true

# Taxon type
# 
# Attributes:
#   created_at [DateTime]
#   data [jsonb]
#   name [string]
#   site_id [Site]
#   slug [string]
#   updated_at [DateTime]
#   uuid [uuid]
class TaxonType < ApplicationRecord
  include HasUuid
  include BelongsToSite

  has_many :taxons, dependent: :delete_all

  validates_presence_of :name, :slug
  validates_uniqueness_of :slug, scope: :site_id

  scope :list_for_administration, -> { order('name asc, slug asc') }
end
