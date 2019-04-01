# frozen_string_literal: true

# Inline post image uploader
class PostIllustrationUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  def store_dir
    slug = "#{model.uuid[0..2]}/#{model.uuid[3..5]}"

    "post_illustrations/#{mounted_as}/#{slug}"
  end

  def default_url(*)
    ActionController::Base.helpers.asset_path('biovision/base/placeholders/3x2.svg')
  end

  version :hd, if: :raster_image? do
    resize_to_fit(1920, 1920)
  end

  version :large, from_version: :hd, if: :raster_image? do
    resize_to_fit(1280, 1280)
  end

  version :medium, from_version: :large, if: :raster_image? do
    resize_to_fit(640, 640)
  end

  version :small, from_version: :medium, if: :raster_image? do
    resize_to_fit(320, 320)
  end

  version :preview, from_version: :small, if: :raster_image? do
    resize_to_fit(160, 160)
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_whitelist
    %w[jpg jpeg png svg svgz]
  end

  # @param [SanitizedFile]
  def raster_image?(new_file)
    !new_file.extension.match?(/svgz?\z/i)
  end

  def raster?
    !File.extname(path).match?(/\.svgz?\z/i)
  end

  def preview_url
    raster? ? preview.url : url
  end

  def small_url
    raster? ? small.url : url
  end

  def medium_url
    raster? ? medium.url : url
  end

  def large_url
    raster? ? large.url : url
  end

  def hd_url
    raster? ? hd.url : url
  end
end
