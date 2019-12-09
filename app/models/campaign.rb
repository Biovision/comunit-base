# frozen_string_literal: true

# Election campaign
#
# Attributes:
#   active [boolean]
#   candidates_count [integer]
#   created_at [DateTime]
#   date [date], optional
#   image [SimpleImageUploader], optional
#   name [string]
#   region_id [Region], optional
#   slug [string]
#   sync_state [JSON]
#   updated_at [DateTime]
#   uuid [uuid]
class Campaign < ApplicationRecord
  include Checkable
  include RequiredUniqueName
  include RequiredUniqueSlug
  include Toggleable

  NAME_LIMIT = 50
  SLUG_LIMIT = 50
  SLUG_PATTERN = /\A[a-z][-_a-z0-9]*[a-z0-9]\z/i.freeze
  SLUG_PATTERN_HTML = '^[a-zA-Z][-_a-zA-Z0-9]*[a-zA-Z0-9]$'

  toggleable :active

  mount_uploader :image, SimpleImageUploader

  belongs_to :region, optional: true
  has_many :candidates, dependent: :delete_all

  after_initialize { self.uuid = SecureRandom.uuid if uuid.nil? }
  before_validation { self.slug = Canonizer.transliterate(name) if slug.blank? }

  validates_uniqueness_of :uuid
  validates_length_of :name, maximum: NAME_LIMIT
  validates_length_of :slug, maximum: SLUG_LIMIT
  validates_format_of :slug, with: SLUG_PATTERN

  scope :active, -> { where(active: true) }
  scope :forthcoming, -> { where('date >= date(now())') }
  scope :ordered_by_date, -> { order('date asc nulls first') }
  scope :list_for_visitors, -> { active.ordered_by_date }
  scope :list_for_administration, -> { ordered_by_slug }

  def self.entity_parameters
    %i[active date image name region_id slug]
  end

  # @param [User] user
  def self.user_can_join?(user)
    total = list_for_visitors.count
    taken = list_for_visitors.joins(:candidates).where(candidates: { user: user }).count
    total > taken
  end

  def regional?
    !region.nil?
  end

  # @param [Candidate] entity
  def candidate?(entity)
    candidates.where(id: entity.id).exists?
  end

  # @param [User] entity
  def user?(entity)
    candidates.owned_by(entity).exists?
  end

  # @param [User] user
  def approved?(user)
    candidates.find_by(user: user)&.approved?
  end
end
