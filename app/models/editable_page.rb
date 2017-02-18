class EditablePage < ApplicationRecord
  include RequiredUniqueName
  include RequiredUniqueSlug

  mount_uploader :image, PostImageUploader

  def self.page_for_administration
    ordered_by_name
  end

  def self.entity_parameters
    %i(image name title keywords description body)
  end

  def self.creation_patameters
    entity_parameters + %i(slug)
  end
end
