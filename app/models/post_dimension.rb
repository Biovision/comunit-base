# frozen_string_literal: true

# Additional post dimension
# 
# Attributes:
#   created_at [DateTime]
#   data [jsonb]
#   name [string]
#   posts_count [integer]
#   priority [integer]
#   site_id [Site]
#   slug [String]
#   updated_at [DateTime]
#   uuid [uuid]
#   visible [boolean]
class PostDimension < ApplicationRecord
  include Checkable
  include HasUuid
  include NestedPriority
  include Toggleable

  NAME_LIMIT = 50
  SLUG_LIMIT = 50
  SLUG_PATTERN = /\A[a-z][-a-z0-9]*[a-z0-9]\z/i.freeze
  SLUG_PATTERN_HTML = '^[a-zA-Z][-a-zA-Z0-9]*[a-zA-Z0-9]$'

  toggleable :visible

  belongs_to :site
  has_many :post_post_dimensions, dependent: :delete_all
  has_many :posts, through: :post_post_dimensions

  validates_presence_of :slug, :name
  validates_uniqueness_of :name, scope: :site_id
  validates_uniqueness_of :slug, scope: :site_id
  validates_length_of :name, maximum: NAME_LIMIT
  validates_length_of :slug, maximum: SLUG_LIMIT
  validates_format_of :slug, with: SLUG_PATTERN

  scope :visible, -> { where(visible: true) }
  scope :list_for_visitors, -> { visible.ordered_by_priority }
  scope :list_for_administration, -> { ordered_by_priority }

  # @param [PostDimension] entity
  def self.siblings(entity)
    where(site: entity&.site)
  end

  def self.entity_parameters
    %i[name priority slug visible]
  end
end
