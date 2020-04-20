# frozen_string_literal: true

# Image for deed gallery
#
# Attributes:
#   caption [String], optional
#   created_at [DateTime]
#   data [JSON]
#   description [Text], optional
#   image [SimpleImageUploader]
#   priority [Integer]
#   updated_at [DateTime]
#   uuid [UUID]
class DeedImage < ApplicationRecord
  include Checkable
  include NestedPriority
  include HasUuid

  CAPTION_LIMIT     = 100
  DESCRIPTION_LIMIT = 32_767

  mount_uploader :image, SimpleImageUploader

  belongs_to :deed

  validates_length_of :caption, maximum: CAPTION_LIMIT
  validates_length_of :description, maximum: DESCRIPTION_LIMIT

  # @param [DeedImage] entity
  def self.siblings(entity)
    where(deed: entity&.deed)
  end
end
