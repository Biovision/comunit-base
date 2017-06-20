class PostCategory < ApplicationRecord
  include Toggleable

  toggleable :visible

  belongs_to :parent, class_name: PostCategory.to_s, optional: true, touch: true
  has_many :children, class_name: PostCategory.to_s, foreign_key: :parent_id
  has_many :posts
  has_many :theme_post_categories, dependent: :destroy

  after_initialize :set_next_priority
  before_validation { self.slug = Canonizer.transliterate(name.to_s) if slug.blank? }
  before_save { self.children_cache.uniq! }

  validates_presence_of :name, :slug, :priority
  validates_uniqueness_of :name, scope: [:parent_id]
  validates_uniqueness_of :slug

  scope :ordered_by_priority, -> { order 'priority asc, name asc' }
  scope :visible, -> { where visible: true, deleted: false }
  scope :for_editor, -> (user) { where(deleted: false, visible: true) }
  scope :for_tree, ->(parent_id = nil) { siblings(parent_id).ordered_by_priority }
  scope :siblings, ->(parent_id) { where(parent_id: parent_id) }

  def self.page_for_administration
    for_tree
  end

  def self.entity_parameters
    %i(name slug priority visible)
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
      PostCategory.where(id: parents_cache.split(',').compact).order('id asc')
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
    children.order('id asc').map { |child| self.children_cache += [child.id] + child.children_cache }
    save!
    parent.cache_children! unless parent.nil?
  end

  def can_be_deleted?
    !locked? && children.count < 1
  end

  # @param [Post] post
  def has_post?(post)
    post.post_category == self
  end

  # @param [Integer] delta
  def change_priority(delta)
    new_priority = priority + delta
    adjacent     = self.class.find_by(parent_id: parent_id, priority: new_priority)
    if adjacent.is_a?(self.class) && (adjacent.id != id)
      adjacent.update!(priority: priority)
    end
    self.update(priority: new_priority)

    self.class.for_tree(parent_id).map { |e| [e.id, e.priority] }.to_h
  end

  private

  def set_next_priority
    if id.nil? && priority == 1
      self.priority = self.class.siblings(parent_id).maximum(:priority).to_i + 1
    end
  end
end
