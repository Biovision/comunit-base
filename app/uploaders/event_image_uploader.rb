class EventImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include CarrierWave::BombShelter

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  resize_to_fit 1920, 1920

  version :medium_2x do
    resize_to_fit 1280, 1280
  end

  version :medium, from_version: :medium_2x do
    resize_to_fit 640, 640
  end

  version :preview_2x, from_version: :medium do
    resize_to_fit 160, 160
  end

  version :preview, from_version: :preview_2x do
    resize_to_fit 80, 80
  end

  def extension_white_list
    %w(jpg jpeg png)
  end
end
