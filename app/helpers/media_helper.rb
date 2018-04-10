module MediaHelper
  # @param [MediaFolder] entity
  def admin_media_folder_link(entity)
    link_to(entity.name, admin_media_folder_path(id: entity.id))
  end

  # @param [MediaFile] entity
  def admin_media_file_link(entity)
    link_to(entity.name, admin_media_file_path(id: entity.id))
  end

  # @param [Region] entity
  def media_spanshot_preview(entity)
    unless entity.snapshot.blank?
      versions = "#{entity.snapshot.preview_2x.url} 2x"
      image_tag(entity.snapshot.preview.url, alt: entity.name, srcset: versions)
    end
  end
end
