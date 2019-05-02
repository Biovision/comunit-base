class Country < ApplicationRecord
  include RequiredUniqueName
  include Toggleable

  NAME_LIMIT     = 50
  SLUG_LIMIT     = 50
  SLUG_PATTERN   = /\A[a-z][-a-z_]*[a-z]\z/
  PRIORITY_RANGE = (1..999)

  toggleable :visible

  has_many :regions, dependent: :nullify

  after_initialize :set_next_priority
  before_validation :normalize_priority

  validates_presence_of :name, :short_name, :locative, :slug
  validates_length_of :name, maximum: NAME_LIMIT
  validates_length_of :short_name, maximum: NAME_LIMIT
  validates_length_of :locative, maximum: NAME_LIMIT
  validates_length_of :slug, maximum: SLUG_LIMIT
  validates_format_of :slug, with: SLUG_PATTERN

  scope :ordered_by_priority, -> { order 'priority asc, name asc' }
  scope :visible, -> { where(visible: true) }
  scope :list_for_visitors, -> { visible.ordered_by_priority }

  def self.page_for_administration
    ordered_by_priority
  end

  def self.entity_parameters
    %i(visible priority name short_name locative slug)
  end

  # @param [Integer] delta
  def change_priority(delta)
    new_priority = priority + delta
    criteria     = { priority: new_priority }
    adjacent     = self.class.find_by(criteria)
    if adjacent.is_a?(self.class) && (adjacent.id != id)
      adjacent.update!(priority: priority)
    end
    self.update(priority: new_priority)

    self.class.ordered_by_priority.map { |e| [e.id, e.priority] }.to_h
  end

  private

  def set_next_priority
    if id.nil? && priority == 1
      self.priority = self.class.maximum(:priority).to_i + 1
    end
  end

  def normalize_priority
    self.priority = PRIORITY_RANGE.first if priority < PRIORITY_RANGE.first
    self.priority = PRIORITY_RANGE.last if priority > PRIORITY_RANGE.last
  end
end
