# frozen_string_literal: true

# Taxon type
# 
# Attributes:
#   active [Boolean]
#   created_at [DateTime]
#   data [jsonb]
#   name [string]
#   slug [string]
#   updated_at [DateTime]
#   uuid [uuid]
class TaxonType < ApplicationRecord
  include BelongsToSite
  include Checkable
  include HasUuid
  include RequiredUniqueSlug
  include Toggleable

  toggleable :active

  has_many :taxa, dependent: :delete_all

  validates_presence_of :name

  scope :active, -> { where(active: true) }
  scope :list_for_administration, -> { order('name asc, slug asc') }

  # @param [String] slug
  def self.[](slug)
    find_by(slug: slug)
  end

  def self.entity_parameters
    %i[active name slug]
  end

  def text_for_link
    name
  end
end
