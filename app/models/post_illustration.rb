# frozen_string_literal: true

# Model for inline post illustration
#
# Attributes
#   agent_id [Agent], optional
#   created_at [DateTime]
#   image [PostIllustrationUploader]
#   ip [Inet], optional
#   updated_at [DateTime]
#   user_id [User], optional
#   uuid [UUID]
class PostIllustration < ApplicationRecord
  include HasOwner

  mount_uploader :image, PostIllustrationUploader

  belongs_to :user, optional: true
  belongs_to :agent, optional: true

  after_create { self.uuid = SecureRandom.uuid if uuid.nil? }

  validates_presence_of :image

  # @param [Hash] parameters
  def self.ckeditor_upload!(parameters)
    entity = new(parameters)
    if entity.save
      entity.ckeditor_data
    else
      {
        uploaded: 0,
        error: 'Could not upload image'
      }
    end
  end

  # Response data for CKEditor upload
  def ckeditor_data
    {
      uploaded: 1,
      fileName: File.basename(image.path),
      url: image.hd_url
    }
  end
end
