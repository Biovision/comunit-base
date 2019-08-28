# frozen_string_literal: true

class PromoBlock < ApplicationRecord
  include Checkable
  include Toggleable
  include RequiredUniqueSlug

  DESCRIPTION_LIMIT = 250
  NAME_LIMIT        = 50
  SLUG_LIMIT        = 50
  SLUG_PATTERN      = /\A[a-z0-9][-_a-z0-9]*[a-z0-9]\z/.freeze
  SLUG_PATTERN_HTML = '^[a-zA-Z0-9][-_a-zA-Z0-9]*[a-zA-Z0-9]$'

  toggleable :visible

  belongs_to :language, optional: true
  has_many :promo_items, dependent: :destroy

  before_validation { self.slug = slug.downcase unless slug.nil? }
  validates_length_of :description, maximum: DESCRIPTION_LIMIT
  validates_length_of :name, maximum: NAME_LIMIT
  validates_format_of :slug, with: SLUG_PATTERN
  validates_length_of :slug, maximum: SLUG_LIMIT

  scope :visible, -> { where(visible: true) }
  scope :list_for_administration, -> { ordered_by_slug }

  # @param [String] slug
  # @param [String] language_code
  def self.localized_block(slug, language_code)
    language = Language.find_by(code: language_code)
    criteria = { visible: true, slug: slug }
    find_by(criteria.merge(language: language)) || find_by(criteria)
  end

  def self.entity_parameters
    %i[description language_id name slug visible]
  end

  # @param [User] user
  def editable_by?(user)
    UserPrivilege.user_has_privilege?(user, :promo_manager)
  end

  # @return [PromoItem]
  def item_for_visitors
    promo_items.list_for_visitors.order('random()').first
  end
end
