class Entry < ApplicationRecord
  # include Elasticsearch::Model
  include HasOwner

  PER_PAGE = 10

  # index_name Rails.configuration.entry_index_name

  belongs_to :agent, optional: true
  belongs_to :user, optional: true, counter_cache: true, touch: false
  belongs_to :community, optional: true, counter_cache: true, touch: false
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :news, dependent: :destroy

  enum privacy: [:generally_accessible, :visible_to_community, :visible_to_followees, :personal]

  mount_uploader :image, PostImageUploader

  before_validation :normalize_title, :sanitize_body

  validates_presence_of :body, :privacy

  scope :not_deleted, -> { where(deleted: false) }
  scope :with_privacy, -> (value) { where(privacy: value) unless value.blank? }
  scope :public_entries, -> { where(privacy: Entry.privacies[:generally_accessible]) }
  scope :recent, -> { order 'id desc' }
  scope :archive, -> (year, month) { where "date_trunc('month', created_at) = ?", '%04d-%02d-01' % [year, month] }
  scope :since, -> (time) { where('created_at > ?', time) }
  scope :popular, -> { order('view_count desc') }

  # @param [Integer] page
  def self.page_for_administration(page)
    not_deleted.with_privacy(Entry.community_privacies).recent.page(page).per(PER_PAGE)
  end

  # @param [User] user
  # @param [Integer] page
  def self.page_for_visitors(user, page)
    not_deleted.with_privacy(Entry.privacy_for_user(user)).recent.page(page).per(PER_PAGE)
  end

  # @param [User] user
  # @param [Integer] page
  def self.page_for_owner(user, page)
    owned_by(user).not_deleted.recent.page(page).per(PER_PAGE)
  end

  def self.community_privacies
    [Entry.privacies[:generally_accessible], Entry.privacies[:visible_to_community]]
  end

  def self.entity_parameters
    for_image = %i(image image_name image_author_name image_author_link)
    for_image + %i(lead title body slug privacy show_name source source_link)
  end

  def self.creation_parameters
    entity_parameters # + %i(community_id)
  end

  # @param [User] user
  def self.privacy_for_user(user)
    user.is_a?(User) ? Entry.community_privacies : Entry.privacies[:generally_accessible]
  end

  # @param [User] user
  def can_be_reposted_by?(user)
    generally_accessible? && UserPrivilege.user_in_group?(user, :editors)
  end

  # Is entry visible to user?
  #
  # @param [User|nil] user who tries to see the entry
  # @return [Boolean]
  def visible_to?(user)
    method = "#{self.privacy}_to?".to_sym
    respond_to?(method) ? send(method, user) : owned_by?(user)
  end

  # Is entry visible to user as generally accessible entry?
  #
  # @param [User|nil] user who tries to see the entry
  # @return [Boolean]
  def generally_accessible_to?(user)
    user.nil? || user.is_a?(User)
  end

  # Is entry visible to user as entry for community?
  #
  # @param [User|nil] user who tries to see the entry
  # @return [Boolean]
  def visible_to_community_to?(user)
    user.is_a? User
  end

  # Is entry visible to user as entry for followees?
  #
  # @param [User|nil] user who tries to see the entry
  # @return [Boolean]
  def visible_to_followees_to?(user)
    owned_by?(user) || (self.user.is_a?(User) && self.user.follows?(user))
  end

  def editable_by?(user)
    owned_by?(user) || (UserPrivilege.user_has_privilege?(user, :administrator) && visible_to?(user))
  end

  # @param [User] user
  def commentable_by?(user)
    user.is_a? User
  end

  private

  def sanitize_body
    self.body = body.gsub(/<\s*(?:no)?script/, '')
  end

  def normalize_title
    if title.blank?
      self.title, self.slug = nil, nil
    else
      self.title = title.strip[0..200]
      self.slug  = Canonizer.transliterate title
    end
  end
end
