class Privilege < ApplicationRecord
  include Toggleable

  DESCRIPTION_LIMIT = 350

  toggleable :regional

  belongs_to :parent, class_name: Privilege.to_s, optional: true
  has_many :children, class_name: Privilege.to_s, foreign_key: :parent_id
  has_many :user_privileges, dependent: :destroy
  has_many :users, through: :user_privileges

  after_initialize :set_next_priority

  before_validation { self.name = name.strip unless name.nil? }
  before_validation { self.slug = Canonizer.transliterate(name.to_s) if slug.blank? }

  before_save :compact_children_cache

  validates_presence_of :name, :slug, :priority
  validates_uniqueness_of :name, scope: [:parent_id]
  validates_uniqueness_of :slug
  validates_length_of :description, maximum: DESCRIPTION_LIMIT

  scope :ordered_by_priority, -> { order('priority asc, name asc') }
  scope :visible, -> { where(visible: true, deleted: false) }
  scope :for_tree, -> (parent_id = nil) { where(parent_id: parent_id).ordered_by_priority }

  def self.page_for_administration
    for_tree
  end

  def self.entity_parameters
    %i(regional name slug priority description)
  end

  def self.creation_parameters
    entity_parameters + %i(parent_id)
  end

  def full_title
    (parents.map { |parent| parent.name } + [name]).join ' / '
  end

  def ids
    [id] + children_cache
  end

  def parents
    if parents_cache.blank?
      []
    else
      Privilege.where(id: parents_cache.split(',').compact).order('id asc')
    end
  end

  def cache_parents!
    if parent.nil?
      self.parents_cache = ''
    else
      self.parents_cache = parent.parents_cache + ",#{parent_id}"
    end
    save!
  end

  def cache_children!
    children.order('id asc').map do |child|
      self.children_cache += [child.id] + child.children_cache
    end
    save!
    parent.cache_children! unless parent.nil?
  end

  def can_be_deleted?
    children.count < 1
  end

  # @param [User] user
  # @param [Region] region
  def has_user?(user, region = nil)
    criteria          = { user: user }
    criteria[:region] = region if regional?
    user_privileges.exists?(criteria) || user&.super_user?
  end

  # @param [User] user
  # @param [Region] region
  def grant(user, region)
    criteria          = { privilege: self, user: user }
    criteria[:region] = region if regional?
    UserPrivilege.create(criteria) unless UserPrivilege.exists?(criteria)
  end

  # @param [User] user
  # @param [Region] region
  def revoke(user, region)
    criteria          = { privilege: self, user: user }
    criteria[:region] = region if regional?
    UserPrivilege.where(criteria).destroy_all
  end

  # @param [Integer] delta
  def change_priority(delta)
    new_priority = priority + delta
    adjacent     = Privilege.find_by(parent_id: parent_id, priority: new_priority)
    if adjacent.is_a?(Privilege) && (adjacent.id != id)
      adjacent.update!(priority: priority)
    end
    self.update(priority: new_priority)

    Privilege.where(parent_id: parent_id).ordered_by_priority.map { |e| [e.id, e.priority] }.to_h
  end

  private

  def set_next_priority
    if id.nil? && priority == 1
      self.priority = Privilege.where(parent_id: parent_id).maximum(:priority).to_i + 1
    end
  end

  def compact_children_cache
    self.children_cache.uniq!
  end
end
