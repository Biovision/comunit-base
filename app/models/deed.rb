# frozen_string_literal: true

# Deed offer of request
#
# Attributes:
#   agent_id [Agent]
#   comments_count [Integer]
#   created_at [DateTime]
#   data [JSON]
#   description [Text], optional
#   done [Boolean]
#   image [SimpleImageUploader]
#   ip [Inet]
#   offer [Boolean]
#   region_id [Region], optional
#   title [String]
#   updated_at [DateTime]
#   user_id [User]
#   uuid [UUID]
#   view_count [Integer]
#   visible [Boolean]
class Deed < ApplicationRecord
  include Checkable
  include HasOwner
  include HasUuid
  include Toggleable

  DESCRIPTION_LIMIT = 65_535
  TITLE_LIMIT = 255

  toggleable :done, :offer, :visible

  mount_uploader :image, SimpleImageUploader

  belongs_to :user
  belongs_to :region, optional: true
  belongs_to :agent, optional: true
  has_many :deed_images, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :delete_all
  has_many :deed_deed_categories, dependent: :destroy
  has_many :deed_categories, through: :deed_deed_categories

  validates_presence_of :title, :description
  validates_length_of :description, maximum: DESCRIPTION_LIMIT
  validates_length_of :title, maximum: TITLE_LIMIT

  scope :recent, -> { order('id desc') }
  scope :visible, -> { where(visible: true) }
  scope :offers, -> { where(offer: true) }
  scope :requests, -> { where(offer: false) }
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

  # @param [User] user
  # @param [Integer] page
  def self.page_for_owner(user, page = 1)
    owned_by(user).recent.page(page)
  end

  def self.entity_parameters
    %i[description done image offer region_id title]
  end

  # @param [User] user
  def commentable_by?(user)
    !user.nil?
  end
end
