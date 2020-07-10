# frozen_string_literal: true

# Country
#
# Attributes:
#   created_at [DateTime]
#   data [Json]
#   image [SimpleImageUploader], optional
#   locative [String]
#   name [String]
#   priority [Integer]
#   regions_count [Integer]
#   short_name [String]
#   slug [String]
#   updated_at [DateTime]
#   visible [Boolean]
class Country < ApplicationRecord
  include Checkable
  include FlatPriority
  include RequiredUniqueName
  include RequiredUniqueSlug
  include Toggleable

  NAME_LIMIT        = 50
  SLUG_LIMIT        = 50
  SLUG_PATTERN      = /\A[a-z][-a-z0-9]*[a-z]\z/i.freeze
  SLUG_PATTERN_HTML = '^[a-zA-Z][-a-zA-Z0-9]*[a-zA-Z]$'

  toggleable :visible

  mount_uploader :image, SimpleImageUploader

  has_many :regions, dependent: :delete_all

  before_validation { self.slug = Canonizer.canonize(name.to_s) if slug.blank?}
  before_validation { self.slug = slug.to_s.downcase }

  validates_presence_of :short_name, :locative
  validates_length_of :name, maximum: NAME_LIMIT
  validates_length_of :short_name, maximum: NAME_LIMIT
  validates_length_of :locative, maximum: NAME_LIMIT
  validates_length_of :slug, maximum: SLUG_LIMIT
  validates_format_of :slug, with: SLUG_PATTERN

  scope :visible, -> { where(visible: true) }
  scope :list_for_visitors, -> { visible.ordered_by_priority }
  scope :list_for_administration, -> { ordered_by_priority }

  def self.entity_parameters
    %i[image locative name short_name slug visible]
  end

  def can_be_deleted?
    regions.count < 1
  end
end
