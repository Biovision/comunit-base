# frozen_string_literal: true

# Decision to make
#
# Attributes:
#   active [boolean]
#   answers [jsonb]
#   body [text]
#   created_at [DateTime]
#   data [jsonb]
#   end_date [date]
#   name [string]
#   simple_image_id [SimpleImage]
#   updated_at [DateTime]
#   uuid [uuid]
#   visible [boolean]
class Decision < ApplicationRecord
  include Checkable
  include HasSimpleImage
  include HasUuid
  include Toggleable

  NAME_LIMIT = 250

  toggleable :active, :visible

  validates_presence_of :body, :name
  validates_length_of :name, maximum: NAME_LIMIT

  scope :visible, -> { where(visible: true) }
  scope :recent, -> { order('id desc') }
  scope :list_for_visitors, -> { visible.recent }
  scope :list_for_administration, -> { recent }

  def self.entity_parameters
    %i[active body end_date name simple_image_id visible]
  end
end
