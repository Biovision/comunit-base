class Photo < ApplicationRecord
  PER_PAGE = 20

  mount_uploader :image, PhotoUploader

  belongs_to :album, counter_cache: true

  after_initialize { self.uuid = SecureRandom.uuid if uuid.nil? }
  after_initialize :set_next_priority

  validates_presence_of :name, :image, :description

  scope :ordered_by_priority, -> { order('priority asc, name asc') }
  scope :siblings, ->(item) { where(album: item&.album) }

  # @param [Integer] page
  def self.page_for_administration(page = 1)
    ordered_by_priority.page(page).per(PER_PAGE)
  end

  # @param [Integer] page
  def self.page_for_visitors(page = 1)
    ordered_by_priority.page(page).per(PER_PAGE)
  end

  def self.entity_parameters
    %i(image name description)
  end

  def self.creation_parameters
    entity_parameters + %i(album_id)
  end

  # @param [Integer] delta
  def change_priority(delta)
    new_priority = priority + delta
    adjacent     = Photo.siblings(self).find_by(priority: new_priority)
    if adjacent.is_a?(Photo) && (adjacent.id != id)
      adjacent.update!(priority: priority)
    end
    update(priority: new_priority)

    Photo.siblings(self).map { |e| [e.id, e.priority] }.to_h
  end

  private

  def set_next_priority
    if id.nil? && priority == 1
      self.priority = Photo.siblings(self).maximum(:priority).to_i + 1
    end
  end
end
