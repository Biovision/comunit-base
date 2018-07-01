class PromoItem < ApplicationRecord
  include Checkable
  include HasOwner
  include Toggleable

  CODE_LIMIT  = 5000
  LEAD_LIMIT  = 250
  META_LIMIT  = 250
  NAME_LIMIT  = 50
  TITLE_LIMIT = 100
  URL_LIMIT   = 250

  toggleable :visible

  mount_uploader :image, PromoImageUploader

  belongs_to :promo_block, counter_cache: true
  belongs_to :user
  belongs_to :agent, optional: true

  validates_presence_of :name
  validates_length_of :code, maximum: CODE_LIMIT
  validates_length_of :lead, maximum: LEAD_LIMIT
  validates_length_of :name, maximum: NAME_LIMIT
  validates_length_of :title, maximum: TITLE_LIMIT
  validates_length_of :url, maximum: URL_LIMIT

  scope :ordered_by_views, -> { order('view_count desc') }
  scope :visible, -> { where(visible: true) }
  scope :list_for_administration, -> { order('id desc') }

  def self.entity_parameters
    %i[code image image_alt_text lead name promo_block_id title url]
  end
end
