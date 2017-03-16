class Album < ApplicationRecord
  include HasOwner
  include Toggleable

  PER_PAGE = 20

  toggleable :show_on_front

  mount_uploader :image, PhotoUploader

  belongs_to :user
  belongs_to :region, optional: true
  has_many :photos, dependent: :destroy

  after_initialize { self.uuid = SecureRandom.uuid if uuid.nil? }
  before_validation { self.slug = Canonizer.transliterate(name.to_s) }

  validates_presence_of :name, :image, :description

  scope :ordered_by_name, -> { order('name asc') }
  scope :recent, -> { order('id desc') }
  scope :for_frontpage, -> { where(show_on_front: true) }

  # @param [Integer] page
  def self.page_for_administration(page = 1)
    recent.page(page).per(PER_PAGE)
  end

  # @param [Integer] page
  def self.page_for_visitors(page = 1)
    recent.page(page).per(PER_PAGE)
  end

  def self.entity_parameters
    %i(name image description)
  end

  # @param [User] user
  def editable_by?(user)
    owned_by?(user)
  end
end
