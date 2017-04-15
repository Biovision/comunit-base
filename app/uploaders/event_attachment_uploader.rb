class EventAttachmentUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id/1000.floor}/#{model.id}"
  end

  def filename
    "#{model.uuid}.#{file.extension}" if original_filename
  end

  def extension_blacklist
    %w(html htm)
  end
end
