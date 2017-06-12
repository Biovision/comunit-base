class MediaFolder < ApplicationRecord
  include HasOwner

  NAME_LIMIT = 100

  mount_uploader :snapshot, MediaSnapshotUploader

  belongs_to :user, optional: true
  belongs_to :agent, optional: true
  belongs_to :parent, class_name: MediaFolder.to_s, optional: true, touch: true
  has_many :children, class_name: MediaFolder.to_s, foreign_key: :parent_id
  has_many :media_files, dependent: :destroy

  after_initialize { self.uuid = SecureRandom.uuid if uuid.nil? }

  before_save { self.children_cache.uniq! }

  before_validation { self.name = name.strip unless name.nil? }

  validates_presence_of :name
  validates_uniqueness_of :name, scope: [:parent_id]
  validates_length_of :name, maximum: NAME_LIMIT
  validates_uniqueness_of :uuid

  scope :ordered_by_name, -> { order('name asc') }
  scope :visible, -> { where(deleted: false) }
  scope :for_tree, ->(parent_id = nil) { where(parent_id: parent_id).ordered_by_name }

  def self.page_for_administration
    for_tree
  end

  def self.entity_parameters
    %i(name flags)
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
      MediaFolder.where(id: parents_cache.split(',').compact).order('id asc')
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
end
