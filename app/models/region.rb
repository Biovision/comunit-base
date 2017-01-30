class Region < ApplicationRecord
  include Toggleable

  SLUG_PATTERN = /\A[a-z0-9](?:[a-z0-9\-]{0,61}[a-z0-9])?\z/
  PER_PAGE = 20

  toggleable :visible

  has_many :news, dependent: :nullify
  has_many :users, dependent: :nullify
  has_many :cities, dependent: :destroy

  mount_uploader :image, RegionImageUploader
  mount_uploader :header_image, HeaderImageUploader

  before_validation { self.slug = slug.to_s.downcase.strip }

  validates_presence_of :name, :slug
  validates_uniqueness_of :name, :slug
  validates_format_of :slug, with: SLUG_PATTERN

  scope :ordered_by_slug, -> { order 'slug asc' }
  scope :ordered_by_name, -> { order 'name asc' }

  # @param [Integer] page
  def self.page_for_administration(page = 1)
    ordered_by_name.page(page).per(PER_PAGE)
  end

  def self.entity_parameters
    %i(visible header_image)
  end
end
