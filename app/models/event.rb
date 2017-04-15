class Event < ApplicationRecord
  include Toggleable

  PER_PAGE = 10

  NAME_LIMIT    = 150
  LEAD_LIMIT    = 500
  ADDRESS_LIMIT = 250
  DAYS_LIMIT    = (1..99)

  toggleable :visible, :active

  has_many :event_participants, dependent: :destroy
  has_many :event_speakers, dependent: :destroy
  has_many :event_sponsors, dependent: :destroy
  has_many :event_programs, dependent: :delete_all

  mount_uploader :image, EventImageUploader

  before_validation { self.name = name.to_s.strip }
  before_validation { self.slug = Canonizer.canonize(name.to_s) }

  validates_presence_of :name, :body
  validates_length_of :lead, maximum: LEAD_LIMIT
  validates_length_of :name, maximum: NAME_LIMIT
  validates_length_of :address, maximum: ADDRESS_LIMIT
  validates_inclusion_of :day_count, in: DAYS_LIMIT

  scope :recent, -> { order('start_date desc, id desc') }
  scope :visible, -> { where(visible: true) }

  # @oaram [Integer] page
  def self.page_for_administration(page = 1)
    recent.page(page).per(PER_PAGE)
  end

  # @param [Integer] page
  def self.page_for_visitors(page = 1)
    visible.recent.page(page).per(PER_PAGE)
  end

  def self.entity_parameters
    %i(name lead body start_date day_count address visible active image)
  end
end
