class EventSpeaker < ApplicationRecord
  include Toggleable

  NAME_LIMIT       = 100
  OCCUPATION_LIMIT = 250
  PRIORITY_LIMIT   = (1..999)

  toggleable :visible

  belongs_to :event

  mount_uploader :image, EventPersonImageUploader

  after_initialize :set_next_priority

  before_validation :normalize_priority
  validates_presence_of :name
  validates_length_of :name, maximum: NAME_LIMIT
  validates_length_of :occupation, maximum: OCCUPATION_LIMIT

  scope :siblings, ->(event) { where(event: event) }
  scope :ordered_by_priority, -> { order('priority asc, name asc') }
  scope :visible, -> { where(visible: true) }

  def self.page_for_administration
    ordered_by_priority
  end

  def self.page_for_visitors
    visible.ordered_by_priority
  end

  def self.entity_parameters
    %i(image name occupation visible priority)
  end

  def self.creation_parameters
    entity_parameters + %i(event_id)
  end

  def locked?
    event.locked?
  end

  # @param [Integer] delta
  def change_priority(delta)
    new_priority = priority + delta
    adjacent     = EventSpeaker.siblings(event).find_by(priority: new_priority)
    if adjacent.is_a?(EventSpeaker) && (adjacent.id != id)
      adjacent.update!(priority: priority)
    end
    self.update(priority: new_priority)

    EventSpeaker.siblings(event).ordered_by_priority.map { |e| [e.id, e.priority] }.to_h
  end

  private

  def set_next_priority
    if id.nil? && priority == 1
      self.priority = EventSpeaker.siblings(event).maximum(:priority).to_i + 1
    end
  end

  def normalize_priority
    self.priority = PRIORITY_LIMIT.first if priority < PRIORITY_LIMIT.first
    self.priority = PRIORITY_LIMIT.last if priority > PRIORITY_LIMIT.last
  end
end
