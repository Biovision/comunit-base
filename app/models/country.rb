# frozen_string_literal: true

# Country.
#
# Only visibility and priority are available for editing. Primary model data
# is in central site.
#
# Attributes:
#   created_at [DateTime]
#   locative [string]
#   name [string]
#   priority [integer]
#   regions_count [integer]
#   short_name [string]
#   slug [string]
#   updated_at [DateTime]
#   visible [boolean]
class Country < ApplicationRecord
  include FlatPriority
  include Toggleable

  toggleable :visible

  has_many :regions, dependent: :delete_all

  scope :visible, -> { where(visible: true) }
  scope :list_for_visitors, -> { visible.ordered_by_priority }
  scope :list_for_administration, -> { ordered_by_priority }

  def self.entity_parameters
    %i[visible priority]
  end
end
