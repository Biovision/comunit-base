# frozen_string_literal: true

# Taxon for categorizing posts
#
# Attributes:
#   children_cache [Array<Integer>]
#   created_at [DateTime]
#   data [jsonb]
#   name [string]
#   nav_text [String]
#   posts_count [integer]
#   parent_id [Taxon]
#   parents_cache [String]
#   priority [integer]
#   site_id [Site]
#   slug [String]
#   updated_at [DateTime]
#   uuid [uuid]
#   visible [boolean]
class Taxon < ApplicationRecord
  include BelongsToSite
  include Checkable
  include HasUuid
  include NestedPriority
  include Toggleable
  include TreeStructure

  NAME_LIMIT = 5000
  NAV_LIMIT = 50
  SLUG_LIMIT = 50
  SLUG_PATTERN = /\A[a-z0-9]([-a-z0-9]*[a-z0-9])?\z/i.freeze
  SLUG_PATTERN_HTML = '^[a-zA-Z0-9]([-a-zA-Z0-9]*[a-zA-Z0-9])?$'

  toggleable :visible

  belongs_to :taxon_type
  has_many :post_taxons, dependent: :delete_all
  has_many :posts, through: :post_taxons

  validates_presence_of :slug, :name
  validates_uniqueness_of :name, scope: %i[site_id taxon_type_id]
  validates_uniqueness_of :slug, scope: %i[site_id taxon_type_id]
  validates_length_of :name, maximum: NAME_LIMIT
  validates_length_of :slug, maximum: SLUG_LIMIT
  validates_format_of :slug, with: SLUG_PATTERN

  before_validation :ensure_parent_match

  scope :for_tree, ->(v = nil) { where(parent_id: v).ordered_by_priority }
  scope :visible, -> { where(visible: true) }
  scope :list_for_visitors, -> { visible.ordered_by_priority }
  scope :list_for_administration, -> { ordered_by_priority }

  # @param [Taxon] entity
  def self.siblings(entity)
    criteria = {
      site: entity&.site,
      taxon_type: entity&.taxon_type,
      parent_id: entity&.parent_id
    }
    where(criteria)
  end

  def self.entity_parameters
    %i[name nav_text priority slug visible]
  end

  def self.creation_parameters
    entity_parameters + %i[parent_id taxon_type_id]
  end

  def text_for_link
    nav_text.blank? ? "#{name[0..50]}…" : nav_text
  end

  # @param [Post] entity
  def post?(entity)
    post_taxons.where(post: entity).exists?
  end

  # @param [Post] entity
  def add_post(entity)
    post_taxons.create(post: entity)
  end

  # @param [Post] entity
  def remove_post(entity)
    post_taxons.where(post: entity).delete_all
  end

  private

  def ensure_parent_match
    return if parent.nil?

    self.taxon_type_id = parent.taxon_type_id
  end
end
