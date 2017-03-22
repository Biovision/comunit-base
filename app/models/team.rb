class Team < ApplicationRecord
  include Toggleable
  include RequiredUniqueName
  include RequiredUniqueSlug

  SLUG_PATTERN = /\A[-_a-z0-9]+\z/

  toggleable :visible

  has_many :team_privileges, dependent: :destroy
  has_many :privileges, through: :team_privileges

  after_initialize :set_next_priority
  before_validation { self.slug = Canonizer.transliterate(name.to_s) if slug.blank? }

  validates_format_of :slug, with: SLUG_PATTERN

  scope :visible, -> { where(visible: true) }
  scope :ordered_by_priority, -> { order('priority asc') }

  def self.page_for_administration
    ordered_by_priority
  end

  def self.page_for_visitors
    visible.ordered_by_priority
  end

  def self.entity_parameters
    %i(name slug priority description visible)
  end

  # @param [Privilege] privilege
  def has_privilege?(privilege)
    team_privileges.where(privilege: privilege).exists?
  end

  # @param [Privilege] privilege
  def add_privilege(privilege)
    TeamPrivilege.find_or_create_by(privilege: privilege, team: self)
  end

  # @param [Privilege] privilege
  def remove_privilege(privilege)
    team_privileges.where(privilege: privilege).destroy_all
  end

  # @param [Integer] delta
  def change_priority(delta)
    new_priority = priority + delta
    adjacent     = Team.find_by(priority: new_priority)
    if adjacent.is_a?(Team) && (adjacent.id != id)
      adjacent.update!(priority: priority)
    end
    self.update(priority: new_priority)

    Team.ordered_by_priority.map { |e| [e.id, e.priority] }.to_h
  end

  private

  def set_next_priority
    if id.nil? && priority == 1
      self.priority = Team.maximum(:priority).to_i + 1
    end
  end
end
