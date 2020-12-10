# frozen_string_literal: true

# Trade union
#
# Attributes:
#   created_at [DateTime]
#   data [jsonb]
#   description [text], optional
#   extra [jsonb]
#   lead [text], optional
#   name [string]
#   simple_image_id [SimpleImage], optional
#   slug [string]
#   updated_at [DateTime]
#   user_count [Integer]
#   uuid [uuid]
class TradeUnion < ApplicationRecord
  include Checkable
  include HasSimpleImage
  include HasUuid
  include BelongsToSite

  LEAD_LIMIT = 1000
  NAME_LIMIT = 250

  has_many :trade_union_documents, dependent: :destroy
  has_many :trade_union_taxa, dependent: :delete_all
  has_many :taxa, through: :trade_union_taxa
  has_many :trade_union_users, dependent: :delete_all
  has_many :users, through: :trade_union_users

  before_validation { self.slug = Canonizer.transliterate(name) }

  validates_presence_of :name
  validates_length_of :lead, maximum: LEAD_LIMIT
  validates_length_of :name, maximum: NAME_LIMIT

  scope :ordered_by_name, -> { order('name asc') }
  scope :list_for_visitors, -> { included_image.ordered_by_name }
  scope :list_for_administration, -> { ordered_by_name }

  # @param [Integer] page
  def self.page_for_administration(page = 1)
    list_for_administration.page(page)
  end

  # @param [Integer] page
  def self.page_for_visitors(page = 1)
    list_for_visitors.page(page)
  end

  def self.entity_parameters
    %i[description lead name simple_image_id]
  end

  def text_for_link
    name
  end

  def world_url
    "/trade_unions/#{id}-#{slug}"
  end
end
