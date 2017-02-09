class Illustration < ApplicationRecord
  include HasOwner

  belongs_to :user, optional: true

  mount_uploader :image, IllustrationImageUploader

  def self.entity_parameters
    %i(name image)
  end
end
