class PhotoUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include CarrierWave::BombShelter

  storage :file
  process :auto_orient

  def auto_orient
    manipulate! do |image|
      image.tap(&:auto_orient)
    end
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id/10000.floor}/#{model.id/100.floor}/#{model.id}"
  end

  def default_url
    ActionController::Base.helpers.asset_path('biovision/base/placeholders/photo.svg')
  end

  resize_to_fit 1920, 1920

  version :medium_2x do
    resize_to_fit 1280, 1280
  end

  version :medium, from_version: :medium_2x do
    resize_to_fit 640, 640
  end

  version :small_2x, from_version: :medium do
    resize_to_fit 320, 320
  end

  version :small, from_version: :small_2x do
    resize_to_fit 160, 160
  end

  version :preview_2x, from_version: :small do
    resize_to_fit 160, 160
  end

  version :preview, from_version: :preview_2x do
    resize_to_fit 80, 80
  end

  def extension_whitelist
    %w(jpg jpeg png)
  end

  def filename
    "#{model.uuid}.#{file.extension}" if original_filename
  end
end
