class EventProgram < ApplicationRecord
  PLACE_LIMIT = 100
  BODY_LIMIT  = 65535

  belongs_to :event

  validates_presence_of :day_number
  validate :day_number_range
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

  def locked?
    event.locked?
  end

  def name
    "#{place}: #{day_number}"
  end

  def max_day_number
    event&.day_count || 1
  end

  private

  def day_number_range
    unless (1..max_day_number).include?(day_number)
      errors.add(:day_number, I18n.t('activerecord.errors.models.event_program.attributes.program_day.out_of_range'))
    end
  end
end
