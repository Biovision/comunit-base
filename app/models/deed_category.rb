# frozen_string_literal: true

# Deed category
#
# Attributes:
#   children_cache [Array<Integer>]
#   created_at [DateTime]
#   data [JSON]
#   deeds_count [Integer]
#   name [String]
#   parent_id [DeedCategory], optional
#   parents_cache [String]
#   priority [Integer]
#   updated_at [DateTime]
#   uuid [UUID]
#   visible [Boolean]
class DeedCategory < ApplicationRecord
  include Checkable
  include HasUuid
  include NestedPriority
  include Toggleable

  NAME_LIMIT = 75

  toggleable :visible

  belongs_to :parent, class_name: DeedCategory.to_s, optional: true
  has_many :child_categories, class_name: DeedCategory.to_s, foreign_key: :parent_id
  has_many :deed_deed_categories, dependent: :delete_all
  has_many :deeds, through: :deed_deed_categories

  before_save { children_cache.uniq! }
  after_create :cache_parents!
  after_save { parent&.cache_children! }

  validates_length_of :name, maximum: NAME_LIMIT
  validates_presence_of :name
  validates_uniqueness_of :name, scope: :parent_id

  scope :visible, -> { where(visible: true) }
  scope :list_for_visitors, -> { visible.ordered_by_priority }
  scope :list_for_administration, -> { ordered_by_priority }

  # @param [DeedCategory] entity
  def self.siblings(entity)
    where(parent_id: entity&.parent_id)
  end

  def self.entity_parameters
    %i[name priority visible]
  end

  def self.creation_parameters
    entity_parameters + %i[parent_id]
  end

  # @param [Deed] deed
  def deed?(deed)
    deed_deed_categories.where(deed: deed).exists?
  end

  # @param [Deed] deed
  def add_deed(deed)
    deed_deed_categories.create(deed: deed)
  end

  # @param [Deed] deed
  def remove_deed(deed)
    deed_deed_categories.where(deed: deed).destroy_all
  end

  def depth
    parents_cache.split(',').count
  end

  def cache_parents!
    return if parent.nil?

    self.parents_cache = "#{parent.parents_cache},#{parent_id}".gsub(/\A,/, '')
    save!
  end

  # @param [Array] new_cache
  def cache_children!(new_cache = [])
    if new_cache.blank?
      new_cache = child_categories.order('id asc').pluck(:id, :children_cache)
    end

    self.children_cache += new_cache.flatten
    self.children_cache.uniq!

    save!
    parent&.cache_children!([id] + children_cache)
  end
end
