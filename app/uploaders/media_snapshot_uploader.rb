class MediaSnapshotUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id/1000.floor}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url(*args)
    ActionController::Base.helpers.asset_path('comunit/base/placeholders/file.svg')
  end

  resize_to_fit(320, 320)

  version :preview_2x do
    resize_to_fit(160, 160)
  end

  version :preview, from_version: :preview_2x do
    resize_to_fit(80, 80)
  end

  def extension_whitelist
    %w(jpg jpeg png)
  end

  def filename
    "#{model.uuid}.#{file.extension}" if original_filename
  end
end
