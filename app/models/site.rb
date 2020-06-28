# frozen_string_literal: true

# Network site
#
# Attributes:
#   active [Boolean]
#   created_at [DateTime]
#   data [JSONB]
#   deleted [Boolean]
#   description [String], optional
#   host [String]
#   image [SimpleImageUploader], optional
#   name [String]
#   updated_at [DateTime]
#   users_count [Integer]
#   uuid [UUID]
class Site < ApplicationRecord
  mount_uploader :image, SimpleImageUploader

  has_many :users, dependent: :nullify

  scope :active, -> { where(active: true, deleted: false) }
  scope :list_for_administration, -> { order('name asc') }

  def self.synchronization_parameters
    ignored = %w(id users_count)
    column_names.reject { |c| ignored.include?(c) }
  end
end
