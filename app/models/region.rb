# frozen_string_literal: true

# Region
#
# Attributes:
#   children_cache [Array<integer>]
#   country_id [Country], optional
#   created_at [DateTime]
#   data [json]
#   header_image [SimpleImageUploader], optional
#   latitude [float]
#   locative [string], optional
#   long_slug [string]
#   longitude [float]
#   map_geometry [text], optional
#   name [string]
#   parent_id [Region], optional
#   parents_cache [string]
#   posts_count [integer]
#   short_name [string], optional
#   slug [string]
#   svg_geometry [text], optional
#   users_count [integer]
#   visible [boolean]
class Region < ApplicationRecord
  include NestedPriority
  include Toggleable

  toggleable :visible

  mount_uploader :header_image, SimpleImageUploader

  belongs_to :country, optional: true, counter_cache: true
  belongs_to :parent, class_name: Region.to_s, optional: true
  has_many :child_regions, class_name: Region.to_s, foreign_key: :parent_id

  validates_presence_of :long_slug, :name, :slug

  scope :ordered_by_slug, -> { order('slug asc') }
  scope :ordered_by_name, -> { order('name asc') }
  scope :visible, -> { where(visible: true) }
  scope :for_tree, ->(country_id = nil, parent_id = nil) { where(parent_id: parent_id).ordered_by_name }

  # @param [Region] item
  def self.siblings(item)
    where(country_id: item&.country_id, parent_id: item&.parent_id)
  end

  def self.entity_parameters
    %i[header_image priority visible]
  end

  def self.synchronization_parameters
    ignored = %w[header_image users_count]

    column_names.reject { |c| ignored.include?(c) }
  end

  # @param [User] user
  def editable_by?(user)
    chief   = UserPrivilege.user_has_privilege?(user, :chief_region_manager)
    manager = UserPrivilege.user_has_privilege?(user, :region_manager, self)
    chief || manager
  end

  def parents
    return [] if parents_cache.blank?

    Region.where(id: parent_ids).order('id asc')
  end

  def parent_ids
    parents_cache.split(',').compact
  end

  # @return [Array<Integer>]
  def branch_ids
    parents_cache.split(',').map(&:to_i).reject { |i| i < 1 }.uniq + [id]
  end

  # @return [Array<Integer>]
  def subbranch_ids
    [id] + children_cache
  end

  def depth
    parent_ids.count
  end

  def long_name
    return name if parents.blank?

    "#{parents.map(&:name).join('/')}/#{name}"
  end

  def branch_name
    return short_name if parents.blank?

    "#{parents.map(&:short_name).join('/')}/#{short_name}"
  end

  def cache_parents!
    return if parent.nil?

    self.parents_cache = "#{parent.parents_cache},#{parent_id}".gsub(/\A,/, '')
    save!
  end

  # @param [Array] new_cache
  def cache_children!(new_cache = [])
    if new_cache.blank?
      new_cache = child_regions.order('id asc').pluck(:id, :children_cache)
    end

    self.children_cache += [new_cache.flatten]
    self.children_cache.uniq!

    save!
    parent&.cache_children!([id] + children_cache)
  end
end
