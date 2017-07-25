class News < ApplicationRecord
  include Elasticsearch::Model
  include HasOwner
  include Toggleable

  PER_PAGE = 20
  LEAD_LIMIT = 350

  index_name Rails.configuration.news_index_name

  toggleable :visible, :show_name, :approved, :allow_comments

  mount_uploader :image, PostImageUploader

  belongs_to :user
  belongs_to :agent, optional: true
  belongs_to :region, optional: true, counter_cache: true, touch: false
  belongs_to :news_category, counter_cache: :items_count
  belongs_to :entry, optional: true
  has_many :figures, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy

  enum post_type: [:news, :comment, :topic]

  before_validation :generate_slug

  validates_presence_of :post_type, :title, :slug, :lead, :body

  scope :popular, -> { order 'view_count desc' }
  scope :in_region, -> (region) { where(region_id: Array(region&.subbranch_ids)) }
  scope :in_category, -> (category) { where(news_category: category) }
  scope :with_category_ids, -> (ids) { where(news_category_id: Array(ids)) }
  scope :of_type, -> (type) { where post_type: News.post_types[type] }
  scope :recent, -> { order 'created_at desc' }
  scope :visible, -> { where visible: true, deleted: false }
  scope :federal, -> { where region_id: nil }

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

  # @param [Region] selected_region
  # @param [Region] excluded_region
  def self.regional(selected_region = nil, excluded_region = nil)
    excluded_ids = Array(excluded_region&.subbranch_ids)
    if selected_region.nil?
      chunk = excluded_ids.any? ? where('region_id not in (?)', excluded_ids) : where('region_id is not null')
    else
      chunk = where(region_id: selected_region.subbranch_ids - excluded_ids)
    end
    chunk
  end

  def self.repost_parameters
    for_image = %i(image image_name image_author_name image_author_link)
    for_image + %i(lead region_id news_category_id show_name source source_link)
  end

  def self.entity_parameters
    repost_parameters + %i(title body post_type slug visible)
  end

  def category
    self.news_category
  end

  def regional?
    region_id.to_i > 0
  end

  # @param [User] user
  def editable_by?(user)
    !deleted? && !locked? && (owned_by?(user) || UserPrivilege.user_has_privilege?(user, :chief_editor))
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
