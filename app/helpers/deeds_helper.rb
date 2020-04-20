# frozen_string_literal: true

# Helper methods for deeds
module DeedsHelper
  # @param [DeedCategory] entity
  # @param [String] text
  # @param [Hash] options
  def admin_deed_category_link(entity, text = entity.name, options = {})
    link_to(text, admin_deed_category_path(id: entity.id), options)
  end

  # @param [Deed] entity
  # @param [String] text
  # @param [Hash] options
  def admin_deed_link(entity, text = entity.title, options = {})
    link_to(text, admin_deed_path(id: entity.id), options)
  end

  # @param [Deed] entity
  # @param [String] text
  # @param [Hash] options
  def my_deed_link(entity, text = entity.title, options = {})
    link_to(text, my_deed_path(id: entity.id), options)
  end

  # @param [Deed] entity
  # @param [String] text
  # @param [Hash] options
  def deed_link(entity, text = entity.title, options = {})
    link_to(text, deed_path(id: entity.id), options)
  end

  def deed_image_medium(entity)

  end
end
