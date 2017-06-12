class MediaFile < ApplicationRecord
  include HasOwner

  PER_PAGE = 50

  NAME_LIMIT        = 250
  DESCRIPTION_LIMIT = 250

  mount_uploader :snapshot, MediaSnapshotUploader
  mount_uploader :file, MediaFileUploader

  belongs_to :media_folder, optional: true, counter_cache: true
  belongs_to :user, optional: true
  belongs_to :agent, optional: true

  after_initialize { self.uuid = SecureRandom.uuid if uuid.nil? }

  before_validation { self.mime_type = mime_type.to_s[0..254] }
  before_validation { self.original_name = original_name.to_s[0..254] }

  validates_length_of :name, maximum: NAME_LIMIT
  validates_length_of :description, maximum: DESCRIPTION_LIMIT
  validates_uniqueness_of :name, scope: [:media_folder_id]
  validates_uniqueness_of :uuid

  scope :ordered_by_name, -> { order('name asc') }
  scope :visible, -> { where(deleted: false) }

  # @param [Integer] page
  def self.page_for_administration(page = 1)
    ordered_by_name.page(page).per(PER_PAGE)
  end

  def self.entity_parameters
    %i(file snapshot name description)
  end

  def self.creation_parameters
    entity_parameters + %i(media_folder_id)
  end
end
