# frozen_string_literal: true

# Post entry
class Post < ApplicationRecord
  include Checkable
  include HasOwner
  include HasUuid
  include CommentableItem
  include VotableItem
  include Toggleable

  ALT_LIMIT = 255
  IMAGE_NAME_LIMIT = 500
  LEAD_LIMIT = 5000
  META_LIMIT = 250
  SLUG_LIMIT = 200
  SLUG_PATTERN = /\A[a-z0-9][-_.a-z0-9]*[a-z0-9]\z/.freeze
  SLUG_PATTERN_HTML = '^[a-zA-Z0-9][-_.a-zA-Z0-9]*[a-zA-Z0-9]$'
  TITLE_LIMIT = 255

  URL_PATTERN = %r{https?://([^/]+)/?.*}.freeze

  toggleable :visible, :show_owner

  mount_uploader :image, PostImageUploader

  paginates_per 12

  belongs_to :region, optional: true
  belongs_to :user, optional: true
  belongs_to :post_type, counter_cache: true
  belongs_to :agent, optional: true
  belongs_to :post_layout, counter_cache: true, optional: true
  belongs_to :simple_image, counter_cache: :object_count, optional: true
  has_many :post_references, dependent: :delete_all
  has_many :post_notes, dependent: :delete_all
  has_many :post_links, dependent: :delete_all
  has_many :post_post_categories, dependent: :destroy
  has_many :post_categories, through: :post_post_categories
  has_many :post_post_tags, dependent: :destroy
  has_many :post_tags, through: :post_post_tags
  has_many :post_images, dependent: :destroy
  has_many :post_attachments, dependent: :destroy
  has_many :post_taxa, dependent: :destroy
  has_many :taxa, through: :post_taxa

  after_initialize { self.publication_time = Time.now if publication_time.nil? }
  before_validation :prepare_slug
  before_validation :prepare_source_names
  before_save :track_region_change

  validates_presence_of :title, :slug, :body
  validates_length_of :title, maximum: TITLE_LIMIT
  validates_length_of :lead, maximum: LEAD_LIMIT
  validates_length_of :image_name, maximum: IMAGE_NAME_LIMIT
  validates_length_of :image_alt_text, maximum: ALT_LIMIT
  validates_length_of :image_source_name, maximum: META_LIMIT
  validates_length_of :image_source_link, maximum: META_LIMIT
  validates_length_of :source_link, maximum: META_LIMIT
  validates_length_of :source_name, maximum: META_LIMIT
  validates_length_of :meta_title, maximum: TITLE_LIMIT
  validates_length_of :meta_description, maximum: META_LIMIT
  validates_length_of :meta_keywords, maximum: META_LIMIT
  validates_length_of :author_name, maximum: META_LIMIT
  validates_length_of :author_title, maximum: META_LIMIT
  validates_length_of :author_url, maximum: META_LIMIT

  scope :in_region, ->(region) { where(region_id: region&.id.nil? ? nil : region&.subbranch_ids) }
  scope :central, -> { where(region_id: nil) }
  scope :for_site, ->(v) { where(site: v) unless v.blank? }
  scope :recent, -> { order('publication_time desc') }
  scope :popular, -> { order('rating desc') }
  scope :visible, -> { where(visible: true, deleted: false, approved: true) }
  scope :published, -> { where('publication_time <= current_timestamp') }
  scope :pg_search, ->(v) { where("posts_tsvector(title, lead, body) @@ phraseto_tsquery('russian', ?)", v) }
  scope :exclude_ids, ->(v) { where('posts.id not in (?)', Array(v)) unless v.blank? }
  scope :list_for_visitors, -> { visible.published.includes(:region, :post_type, :user).recent }
  scope :list_for_administration, -> { includes(:region, :post_type, :user).order('id desc') }
  scope :list_for_owner, ->(v) { includes(:region, :post_type, :user).owned_by(v).recent }
  scope :tagged, ->(v) { joins(:post_post_tags).where(post_post_tags: { post_tag_id: PostTag.ids_for_name(v) }).distinct unless v.blank? }
  scope :in_category, ->(v) { joins(:post_post_categories).where(post_post_categories: { post_category_id: PostCategory.ids_for_slug(v) }).distinct unless v.blank? }
  scope :in_category_branch, ->(v) { joins(:post_post_categories).where(post_post_categories: { post_category_id: v.subbranch_ids }).distinct }
  scope :with_category_ids, ->(v) { joins(:post_post_categories).where(post_post_categories: { post_category_id: Array(v) }) }
  scope :with_taxon_ids, ->(v) { joins(:post_taxa).where(post_taxa: { taxon_id: Array(v) }) unless v.blank? }
  scope :authors, -> { User.where(id: Post.author_ids).order('screen_name asc') }
  scope :of_type, ->(v) { where(post_type: PostType.find_by(slug: v)) unless v.blank? }
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
    main_data = %i[body lead post_layout_id publication_time region_id slug title]
    image_data = %i[image image_alt_text image_source_link image_source_name image_name]
    meta_data = %i[rating source_name source_link meta_title meta_description meta_keywords time_required]
    flags_data = %i[allow_comments allow_votes show_owner visible]
    author_data = %i[author_name author_title author_url]

    main_data + image_data + meta_data + author_data + flags_data
  end

  # @param [Region] selected_region
  # @param [Region] excluded_region
  def self.regional(selected_region = nil, excluded_region = nil)
    excluded_ids = Array(excluded_region&.subbranch_ids)
    if selected_region.nil?
      excluded_ids.any? ? where('region_id not in (?)', excluded_ids) : where('region_id is not null')
    else
      where(region_id: selected_region.subbranch_ids - excluded_ids)
    end
  end

  def self.creation_parameters
    entity_parameters + %i[post_type_id]
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

  def site
    Site.find_by(uuid: data.dig('comunit', 'site_id'))
  end

  def text
    parsed_body.blank? || created_at > 1.year.ago ? body : parsed_body
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

  # Get the most suitable author name for post
  def author!(default_name = '')
    return default_name unless show_owner?

    if author_name.blank?
      user&.profile_name
    else
      author_name
    end
  end

  def url(*)
    "/#{post_type.url_part}/#{id}-#{slug}"
  end

  # @param [String] tag_name
  # @param [Symbol] locale
  def tagged_path(tag_name, _locale = I18n.default_locale)
    "/#{post_type.url_part}/tagged/#{CGI.escape(tag_name)}"
  end

  def enclosures
    body.scan(/<img[^>]+>/).map do |image|
      image.scan(/src="([^"]+)"/)[0][0]
    end
  end

  # Get editorial member instance for this post
  #
  # If user can be shown and is member of editorial, this method returns
  # instance of [EditorialMember] through user for this post of nil otherwise
  #
  # @return [EditorialMember|nil]
  def editorial_member
    return unless show_owner? && author_name.blank?

    EditorialMember.owned_by(user).first
  end

  # List of linked posts for visitors
  #
  # @param [Integer] quantity
  def linked_posts(quantity = 5)
    result = []
    post_links.ordered_by_priority.first(quantity).each do |link|
      result << link.other_post if link.other_post.visible_to_visitors?
    end
    excluded = result.map(&:id)
    delta = quantity - result.count
    result += similar_posts(delta, excluded) if result.count < quantity
    result
  end

  # @param [Integer] quantity
  # @param [Array] excluded
  def similar_posts(quantity = 3, excluded = [])
    result = []

    collection = Post.joins(:post_post_categories).where(post_post_categories: { post_category_id: post_category_ids }).distinct.exclude_ids(excluded + [id])
    collection.visible.popular.first(quantity).each do |post|
      result << post
    end

    result
  end

  def post_category
    post_categories.first
  end

  def locale
    ''
  end

  def translations
    {}
  end

  def visible_to_visitors?
    visible? && !deleted? && approved?
  end

  # @param [User] user
  # @deprecated use component handler
  def editable_by?(user)
    Biovision::Components::PostsComponent[user].editable?(self)
  end

  def has_image_data?
    !image_name.blank? || !image_source_name.blank? || !image_source_link.blank?
  end

  def has_source_data?
    !source_name.blank? || !source_link.blank?
  end

  def tags_string
    post_tags.ordered_by_slug.map(&:name).join(', ')
  end

  # @param [String] input
  def tags_string=(input)
    list = []
    input.split(/,\s*/).reject(&:blank?).each do |tag_name|
      list << PostTag.match_or_create_by_name(post_type_id, tag_name.squish)
    end
    self.post_tags = list.uniq
    cache_tags!
  end

  def cache_tags!
    update! tags_cache: post_tags.order('slug asc').map(&:name)
  end

  def commentable_by?(user)
    allow_comments? && !user.nil?
  end

  private

  def prepare_slug
    postfix = (created_at || Time.now).strftime('%d%m%Y')

    if slug.blank?
      self.slug = "#{Canonizer.transliterate(title.to_s)}_#{postfix}"
    end

    slug_limit = 200 + postfix.length + 1
    self.slug = slug.downcase[0..slug_limit]
  end

  def track_region_change
    return unless region_id_changed?

    Region.update_post_count(*region_id_change)
  end

  def prepare_source_names
    prepare_image_source
    prepare_source
  end

  def prepare_image_source
    return unless image_source_name.blank? && !image_source_link.blank?

    begin
      self.image_source_name = URI.parse(image_source_link).host
    rescue URI::InvalidURIError
      self.image_source_name = URL_PATTERN.match(image_source_link)[1]
    end
  end

  def prepare_source
    return unless source_name.blank? && !source_link.blank?

    begin
      self.source_name = URI.parse(source_link).host
    rescue URI::InvalidURIError
      self.source_name = URL_PATTERN.match(source_link)[1]
    end
  end
end
