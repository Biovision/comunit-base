module AlbumsHelper
  # @param [Album] entity
  def admin_album_link(entity)
    link_to(entity.name, admin_album_path(entity.id))
  end

  # @param [Photo] entity
  def admin_photo_link(entity)
    link_to(entity.name, admin_photo_path(entity.id))
  end

  # @param [Album] entity
  def album_link(entity)
    link_to(entity.name, album_path(entity.id))
  end

  # @param [Album] entity
  def album_image_preview(entity)
    unless entity.image.blank?
      versions = "#{entity.image.preview_2x.url} 2x"
      image_tag(entity.image.preview.url, alt: entity.name, srcset: versions)
    end
  end

  # @param [Album] entity
  def album_image_medium(entity)
    unless entity.image.blank?
      versions = "#{entity.image.medium_2x.url} 2x"
      image_tag(entity.image.medium.url, alt: entity.name, srcset: versions)
    end
  end
end
