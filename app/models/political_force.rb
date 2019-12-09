# frozen_string_literal: true

# Political force
#
# Attributes:
#   candidates_count [integer]
#   created_at [DateTime]
#   data [jsonb]
#   flare [string], optional
#   image [string], optional
#   name [string]
#   slug [string]
#   sync_state [JSON]
#   updated_at [DateTime]
#   uuid [UUID]
class PoliticalForce < ApplicationRecord
  include Checkable
  include RequiredUniqueName
  include RequiredUniqueSlug

  FLARE_LIMIT = 20
  NAME_LIMIT = 100
  SLUG_LIMIT = 20
  SLUG_PATTERN = /\A[a-z][-_a-z]+[a-z]\z/.freeze
  SLUG_PATTERN_HTML = '^[a-zA-Z][-_a-zA-Z]+[a-zA-Z]$'

  mount_uploader :image, SimpleImageUploader

  has_many :candidate_political_forces, dependent: :delete_all
  has_many :candidates, through: :candidate_political_forces

  after_initialize { self.uuid = SecureRandom.uuid if uuid.nil? }

  before_validation { self.slug = slug.to_s.downcase }
  validates_uniqueness_of :uuid
  validates_length_of :flare, maximum: FLARE_LIMIT
  validates_length_of :name, maximum: NAME_LIMIT
  validates_length_of :slug, maximum: SLUG_LIMIT
  validates_format_of :slug, with: SLUG_PATTERN

  scope :list_for_visitors, -> { ordered_by_name }
  scope :list_for_administration, -> { ordered_by_name }

  def self.entity_parameters
    %i[flare image name slug]
  end

  # @param [Candidate] entity
  def candidate?(entity)
    candidate_political_forces.where(candidate: entity).exists?
  end

  # @param [Candidate] entity
  def add_candidate(entity)
    candidate_political_forces.create(candidate: entity)
  end

  # @param [Candidate] entity
  def remove_candidate(entity)
    candidate_political_forces.where(candidate: entity).destroy_all
  end
end
