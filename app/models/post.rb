# frozen_string_literal: true

# Post
#
# Attributes:
#   agent_id [Agent], optional
#   body [text]
#   comments_count [integer]
#   created_at [DateTime]
#   data [jsonb]
#   featured [boolean]
#   ip [inet]
#   lead [text]
#   publication_time [datetime]
#   rating [float]
#   show_owner [boolean]
#   simple_image_id [SimpleImage], optional
#   slug [string]
#   title [string]
#   source_name [string], optional
#   source_link [string], optional
#   updated_at [DateTime]
#   user_id [User]
#   uuid [uuid]
#   view_count [integer]
#   visible [boolean]
class Post < ApplicationRecord
  include BelongsToSite
  include Checkable
  include HasOwner
  include HasUuid
  include HasSimpleImage
  include CommentableItem
  include VotableItem
  include Toggleable

  LEAD_LIMIT = 5000
  META_LIMIT = 250
  SLUG_LIMIT = 200
  SLUG_PATTERN = /\A[a-z0-9][-_.a-z0-9]*[a-z0-9]\z/.freeze
  SLUG_PATTERN_HTML = '^[a-zA-Z0-9][-_.a-zA-Z0-9]*[a-zA-Z0-9]$'
  TITLE_LIMIT = 255

  URL_PATTERN = %r{https?://([^/]+)/?.*}.freeze

  toggleable :visible, :show_owner, :featured

  # mount_uploader :image, PostImageUploader

  paginates_per 12

  belongs_to :user, optional: true
  belongs_to :agent, optional: true
  has_many :post_references, dependent: :delete_all
  has_many :post_notes, dependent: :delete_all
  has_many :post_links, dependent: :delete_all
  has_many :post_images, dependent: :destroy
  has_many :post_attachments, dependent: :destroy
  has_many :post_taxa, dependent: :destroy
  has_many :taxa, through: :post_taxa

  after_initialize { self.publication_time = Time.now if publication_time.nil? }
  before_validation :prepare_slug
  before_validation :prepare_source_names

  validates_presence_of :title, :slug, :body
  validates_length_of :title, maximum: TITLE_LIMIT
  validates_length_of :lead, maximum: LEAD_LIMIT
  validates_length_of :source_link, maximum: META_LIMIT
  validates_length_of :source_name, maximum: META_LIMIT

  scope :featured, -> { where(featured: true) }
  scope :visible, -> { where(visible: true) }
  scope :recent, -> { order('publication_time desc') }
  scope :popular, -> { order('rating desc') }
  scope :published, -> { where('publication_time <= current_timestamp') }
  scope :search, ->(v) { where("posts_tsvector(title, lead, body) @@ phraseto_tsquery('russian', ?)", v) }
  scope :exclude_ids, ->(v) { where('posts.id not in (?)', Array(v)) unless v.blank? }
  scope :with_taxon_ids, ->(v) { joins(:post_taxa).where(post_taxa: { taxon_id: Array(v) }) }
  scope :list_for_visitors, -> { visible.published.includes(:simple_image, :user).recent }
  scope :list_for_administration, -> { includes(:simple_image, :user).order('id desc') }
  scope :list_for_owner, ->(v) { includes(:simple_image, :user).owned_by(v).recent }
  scope :archive, -> { f = Arel.sql('date(publication_time)'); distinct.order(f).pluck(f) }
  scope :posted_after, ->(v) { where('publication_time >= ?', v) }
  scope :pubdate, ->(v) { where('date(publication_time) = ?', v) }
  scope :f_visible, ->(f) { where(visible: f.to_i.positive?) unless f.blank? }
  scope :filtered, ->(f) { f_visible(f[:visible]) }

  # @param [Integer] page
  # @param [Hash] filter
  def self.page_for_administration(page = 1, filter = {})
    filtered(filter).list_for_administration.page(page)
  end

  # @param [Integer] page
  # @param [Integer] per_page
  def self.page_for_visitors(page = 1)
    list_for_visitors.page(page)
  end

  # @param [User] user
  # @param [Integer] page
  def self.page_for_owner(user, page = 1)
    list_for_owner(user).page(page)
  end

  def self.entity_parameters
    %i[
      body featured lead publication_time rating show_owner simple_image_id
      slug source_name source_link title visible
    ]
  end

  def self.author_ids
    visible.pluck(:user_id).uniq
  end

  # @param [Array] array
  def self.archive_dates(array)
    dates = Hash.new { |h, k| h[k] = Hash.new { [] } }
    array.each { |date| dates[date.year][date.month] <<= date.day }
    dates
  end

  # Lead or the first passage of body
  def lead!
    if lead.blank?
      pattern = %r{<p>(.+?)</p>}
      passage = body.match(pattern)
      (passage.nil? ? body.gsub(/<[^>]+>/, '') : passage[1]).to_s[0..499]
    else
      lead
    end
  end

  def world_url
    "/posts/#{id}-#{slug}"
  end

  # List of linked posts for visitors
  #
  # @param [Integer] quantity
  def linked_posts(quantity = 5)
    result = []
    post_links.ordered_by_priority.first(quantity).each do |link|
      result << link.other_post if link.other_post.visible_to_visitors?
    end
    result
  end

  # @param [User] user
  def editable_by?(user)
    Biovision::Components::PostsComponent[user].editable?(self)
  end

  def text_for_link
    title
  end

  private

  def prepare_slug
    postfix = (created_at || Time.now).strftime('%d%m%Y')

    self.slug = "#{Canonizer.transliterate(title.to_s)}_#{postfix}" if slug.blank?

    slug_limit = 200 + postfix.length + 1
    self.slug = slug.downcase[0..slug_limit]
  end

  def prepare_source_names
    return unless source_name.blank? && !source_link.blank?

    self.source_name = URI.parse(source_link).host
  rescue URI::InvalidURIError
    self.source_name = URL_PATTERN.match(source_link)[1]
  end
end
