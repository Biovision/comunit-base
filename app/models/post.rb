class Post < ApplicationRecord
  include Elasticsearch::Model
  include HasOwner
  include Toggleable

  PER_PAGE    = 10
  TITLE_LIMIT = 200
  LEAD_LIMIT  = 350

  index_name Rails.configuration.post_index_name

  toggleable :visible, :main_post, :show_name, :approved, :allow_comments

  belongs_to :user
  belongs_to :agent, optional: true
  belongs_to :post_category, counter_cache: :items_count
  belongs_to :entry, optional: true
  has_many :figures, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy

  validates_presence_of :title, :lead, :body
  validates_length_of :title, maximum: TITLE_LIMIT
  validates_length_of :lead, maximum: LEAD_LIMIT

  before_validation :generate_slug

  mount_uploader :image, PostImageUploader

  scope :in_category, -> (category) { with_category_ids category.ids }
  scope :with_category_ids, -> (ids) { where(post_category_id: ids) }
  scope :recent, -> { order 'id desc' }
  scope :popular, -> { order 'view_count desc' }
  scope :visible, -> { where(deleted: false, visible: true) }
  scope :tagged, -> (tag) { joins(:post_tags).where(post_tags: { tag: tag }) }
  scope :archive, -> (year, month) { where "date_trunc('month', created_at) = ?", '%04d-%02d-01' % [year, month] }

  # @param [Integer] page
  def self.page_for_administration(page)
    recent.page(page).per(PER_PAGE)
  end

  # @param [Integer] page
  def self.page_for_visitors(page)
    visible.recent.page(page).per(PER_PAGE)
  end

  # @param [User] user
  # @param [Integer] page
  def self.page_for_owner(user, page)
    owned_by(user).where(deleted: false).recent.page(page).per(PER_PAGE)
  end

  def self.repost_parameters
    for_image = %i(image image_name image_author_name image_author_link)
    for_image + %i(lead post_category_id show_name source source_link)
  end

  def self.entity_parameters
    repost_parameters + %i(title body main_post slug)
  end

  def tags_string
    tags.ordered_by_slug.map { |tag| tag.name }.join(', ')
  end

  # @param [String] tags_string
  def tags_string=(tags_string)
    list_of_tags = []
    tags_string.split(/,\s*/).reject { |tag_name| tag_name.blank? }.each do |tag_name|
      list_of_tags << Tag.match_or_create_by_name(tag_name.squish)
    end
    self.tags = list_of_tags.uniq
  end

  def category
    post_category
  end

  def cache_tags!
    update! tags_cache: tags.order('slug asc').map { |tag| tag.name }
  end

  # @param [User] user
  def editable_by?(user)
    !deleted? && !locked? && (owned_by?(user) || UserRole.user_has_role?(user, :chief_editor))
  end

  # @param [User] user
  def commentable_by?(user)
    visible? && !deleted? && user.is_a?(User)
  end

  # @param [User] user
  def visible_to?(user)
    visible? || editable_by?(user)
  end

  private

  def generate_slug
    if slug.blank?
      postfix   = (created_at || Time.now).strftime('%d%m%Y')
      self.slug = "#{Canonizer.transliterate(title.to_s)}_#{postfix}"
    end
  end
end
