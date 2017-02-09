class IllustrationImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include CarrierWave::BombShelter

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id/10000.floor}/#{model.id/100.floor}/#{model.id}"
  end

  resize_to_fit 1920, 1920

  version :medium_2x do
    resize_to_fit 960, 960
  end

  version :medium, from_version: :medium do
    resize_to_fit 480, 480
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
