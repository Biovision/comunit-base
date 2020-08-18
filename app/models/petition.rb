# frozen_string_literal: true

# Petition
#
# Attributes:
#   active [boolean]
#   agent_id [Agent], optional
#   created_at [DateTime]
#   data [jsonb]
#   description [text]
#   ip [inet], optional
#   petition_signs_count [integer]
#   title [string]
#   updated_at [DateTime]
#   user_id [User], optional
#   uuid [uuid]
#   visible [boolean]
class Petition < ApplicationRecord
  include Checkable
  include HasOwner
  include HasUuid
  include Toggleable

  TITLE_LIMIT = 250

  toggleable :visible, :active

  belongs_to :user, optional: true
  belongs_to :agent, optional: true

  has_many :petition_signs, dependent: :delete_all

  validates_length_of :title, maximum: TITLE_LIMIT

  scope :visible, -> { where(visible: true) }
  scope :recent, -> { order('id desc') }
  scope :list_for_visitors, -> { visible.recent }
  scope :list_for_administration, -> { recent }

  # @param [Integer] page
  def self.page_for_administration(page = 1)
    list_for_administration.page(page)
  end

  # @param [Integer] page
  def self.page_for_visitors(page = 1)
    list_for_visitors.page(page)
  end

  def self.entity_parameters
    %i[active description title visible]
  end
end
