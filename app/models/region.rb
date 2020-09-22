# frozen_string_literal: true

# Region
# 
# Attributes:
#   children_cache [Array<Integer>]
#   country_id [Country]
#   created_at [DateTime]
#   data [Json]
#   image [RegionImageUploader]
#   latitude [Float], optional
#   locative [String]
#   longitude [Float], optional
#   long_slug [String]
#   name [String]
#   parent_id [Region], optional
#   parents_cache [String]
#   priority [Integer]
#   short_name [String]
#   slug [String]
#   updated_at [DateTime]
#   uuid [UUID]
#   visible [Boolean]
class Region < ApplicationRecord
  include Checkable
  include HasUuid
  include NestedPriority
  include Toggleable
  include TreeStructure

  NAME_LIMIT        = 70
  SLUG_LIMIT        = 63
  SLUG_PATTERN      = /\A[a-z0-9](?:[-a-z0-9]*[a-z0-9])?\z/i.freeze
  SLUG_PATTERN_HTML = '^[a-zA-Z0-9](?:[-a-zA-Z0-9]*[a-zA-Z0-9])?$'

  toggleable :visible

  belongs_to :country, optional: true, counter_cache: true

  before_validation { self.slug = slug.to_s.downcase.strip }
  before_validation { self.country_id = parent.country_id unless parent.nil? }
  before_save :generate_long_slug

  validates_presence_of :name, :slug
  validates_uniqueness_of :name, :slug, scope: %i[country_id parent_id]
  validates_length_of :name, maximum: NAME_LIMIT
  validates_length_of :slug, maximum: SLUG_LIMIT
  validates_format_of :slug, with: SLUG_PATTERN

  scope :ordered_by_slug, -> { order('slug asc') }
  scope :ordered_by_name, -> { order('name asc') }
  scope :in_country, ->(v) { where(country: v) }
  scope :visible, -> { where(visible: true) }
  scope :with_posts, -> { where('posts_count > 0') }
  scope :only_with_ids, ->(v) { where(id: v) unless v.nil? }
  scope :for_tree, ->(country_id = nil, parent_id = nil) { where(parent_id: parent_id).ordered_by_name }
  scope :list_for_visitors, -> { visible.ordered_by_priority }
  scope :list_for_administration, -> { ordered_by_name }

  # @param [Region] item
  def self.siblings(item)
    where(country_id: item&.country_id, parent_id: item&.parent_id)
  end

  # @param [Integer] page
  def self.page_for_administration(page = 1)
    list_for_administration.page(page)
  end

  def self.entity_parameters
    %i[name image latitude locative longitude short_name slug visible]
  end

  def self.creation_parameters
    entity_parameters + %i[country_id parent_id]
  end

  # Post moved to other region
  #
  # Decrements posts_count for region with old_id and increments for new_id
  #
  # @param [Integer|nil] old_id
  # @param [Integer|nil] new_id
  def self.update_post_count(old_id, new_id)
    part = 'update regions set posts_count = posts_count'
    unless new_id.nil?
      region = find(new_id)
      connection.execute("#{part} + 1 where id in (#{region.branch_ids.join(',')})")
    end
    return if old_id.nil?

    region = find(old_id)
    connection.execute("#{part} - 1 where id in (#{region.branch_ids.join(',')})")
  end

  # @param [User] user
  def editable_by?(user)
    Biovision::Components::RegionsComponent[user].allow?('manager')
  end

  def long_name
    return name if parents.blank?

    "#{parents.map(&:name).join('/')}/#{name}"
  end

  def branch_name
    return short_name if parents.blank?

    "#{parents.map(&:short_name).join('/')}/#{short_name}"
  end

  # @param [User] user
  def add_user(user)
    RegionUser.create(region: self, user: user)
  end

  # @param [User] user
  def remove_user(user)
    RegionUser.where(region: self, user: user).delete_all
  end

  private

  def generate_long_slug
    if parents_cache.blank?
      self.long_slug = slug
    else
      slugs = Region.where(id: parent_ids).order('id asc').pluck(:slug) + [slug]

      self.long_slug = slugs.join('_')
    end
  end
end
