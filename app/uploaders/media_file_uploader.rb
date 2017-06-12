class MediaFileUploader < CarrierWave::Uploader::Base
  storage :file
  # storage :fog

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id/1000.floor}/#{model.id}"
  end

  def filename
    "#{model.uuid}.#{file.extension}" if original_filename
  end
end
