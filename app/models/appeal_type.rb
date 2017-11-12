class AppealType < ApplicationRecord
  include RequiredUniqueName
  include Toggleable

  NAME_LIMIT = 50
  PRIORITY_RANGE = (1..100)

  toggleable :visible

  has_many :appeals, dependent: :nullify

  after_initialize :set_next_priority
  validates_length_of :name, maximum: NAME_LIMIT

  scope :ordered_by_priority, -> { order('priority asc, name asc') }
  scope :visible, -> { where(visible: true) }

  def self.page_for_administration
    ordered_by_priority
  end

  def self.list_for_visitors
    visible.ordered_by_priority
  end

  # @param [Integer] delta
  def change_priority(delta)
    new_priority = priority + delta
    adjacent     = self.class.find_by(priority: new_priority)
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
end
