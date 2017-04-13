class EventProgram < ApplicationRecord
  PLACE_LIMIT = 100
  BODY_LIMIT  = 65535

  belongs_to :event

  validates_presence_of :day_number
  validates_inclusion_of :day_number, in: (1..event.day_count)
  validates_uniqueness_of :place, scope: [:day_number, :event_id]
  validates_length_of :place, maximum: PLACE_LIMIT
  validates_length_of :body, maximum: BODY_LIMIT

  scope :ordered_by_day, -> { order('day_number asc, place asc') }

  def self.page_for_administration
    ordered_by_day
  end

  def self.page_for_visitors
    ordered_by_day
  end

  def self.entity_parameters
    %i(place day_number body)
  end

  def self.creation_parameters
    entity_parameters + %i(event_id)
  end
end
