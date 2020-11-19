# frozen_string_literal: true

# Taxon for categorizing posts
#
# Attributes:
#   children_cache [Array<Integer>]
#   created_at [DateTime]
#   data [jsonb]
#   name [string]
#   nav_text [String], optional
#   object_count [integer]
#   parent_id [Taxon], optional
#   parents_cache [String]
#   priority [integer]
#   simple_image_id [SimpleImage], optional
#   slug [String]
#   taxon_type_id [TaxonType]
#   updated_at [DateTime]
#   uuid [uuid]
#   visible [boolean]
class Taxon < ApplicationRecord
  include BelongsToSite
  include Checkable
  include HasSimpleImage
  include HasUuid
  include NestedPriority
  include Toggleable
  include TreeStructure

  NAME_LIMIT = 5000
  NAV_LIMIT = 50
  SLUG_LIMIT = 50
  SLUG_PATTERN = /\A[a-z0-9]([-_a-z0-9]*[a-z0-9])?\z/i.freeze
  SLUG_PATTERN_HTML = '^[a-zA-Z0-9]([-a-zA-Z0-9_]*[a-zA-Z0-9])?$'

  toggleable :visible

  belongs_to :taxon_type
  has_many :taxon_users, dependent: :delete_all
  has_many :users, through: :taxon_users
  has_many :post_taxa, dependent: :delete_all
  has_many :posts, through: :post_taxa
  has_many :post_group_taxa, dependent: :delete_all
  has_many :taxa, through: :post_group_taxa

  validates_presence_of :slug, :name
  validates_length_of :name, maximum: NAME_LIMIT
  validates_length_of :slug, maximum: SLUG_LIMIT
  validates_format_of :slug, with: SLUG_PATTERN

  before_validation :ensure_parent_match

  scope :for_tree, ->(v = nil) { included_image.where(parent_id: v).ordered_by_priority }
  scope :visible, -> { where(visible: true) }
  scope :list_for_visitors, -> { included_image.visible.ordered_by_priority }
  scope :list_for_administration, -> { included_image.includes(:taxon_type).ordered_by_priority }

  # @param [Integer] page
  def self.page_for_administration(page = 1)
    list_for_administration.page(page)
  end

  # @param [Taxon] entity
  def self.siblings(entity)
    criteria = { taxon_type: entity&.taxon_type, parent_id: entity&.parent_id }
    if entity.nil?
      where(criteria)
    elsif entity.site.nil?
      where(criteria).where("coalesce(data->'comunit'->>'site_id', '') = ''")
    else
      where(criteria).where("data->'comunit'->>'site_id' = ?", entity.site.uuid)
    end
  end

  def self.entity_parameters
    %i[name nav_text priority simple_image_id slug visible]
  end

  def self.creation_parameters
    entity_parameters + %i[parent_id taxon_type_id]
  end

  def text_for_link
    if nav_text.blank?
      name.length > 50 ? "#{name[0..49]}…" : name
    else
      nav_text
    end
  end

  # @param [Post] entity
  def post?(entity)
    post_taxa.where(post: entity).exists?
  end

  # @param [Post] entity
  def add_post(entity)
    post_taxa.create(post: entity)
  end

  # @param [Post] entity
  def remove_post(entity)
    post_taxa.where(post: entity).delete_all
  end

  # @param [PostGroup] entity
  def post_group?(entity)
    post_group_taxa.where(post_group: entity).exists?
  end

  # @param [PostGroup] entity
  def add_post_group(entity)
    post_group_taxa.create(post_group: entity)
  end

  # @param [PostGroup] entity
  def remove_post_group(entity)
    post_group_taxa.where(post_group: entity).delete_all
  end

  # @param [User] entity
  def user?(entity)
    taxon_users.where(user: entity).exists?
  end

  # @param [User] entity
  def add_user(entity)
    return if entity.nil?

    taxon_users.create(user: entity)
  end

  # @param [User] entity
  def remove_user(entity)
    return if entity.nil?

    taxon_users.where(user: entity).delete_all
  end

  private

  def ensure_parent_match
    return if parent.nil?

    self.taxon_type_id = parent.taxon_type_id
  end
end
