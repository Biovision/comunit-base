module PromoHelper
  # @param [PromoBlock] entity
  def admin_promo_block_link(entity)
    text = entity.name.blank? ? entity.slug : entity.name
    link_to(text, admin_promo_block_path(id: entity.id))
  end

  # @param [PromoItem] entity
  def admin_promo_item_link(entity)
    link_to(entity.name, admin_promo_item_path(id: entity.id))
  end

  # @param [PromoItem] entity
  def promo_image_large(entity)
    return '' if entity.image.blank?

    alt_text = entity.image_alt_text
    image_tag(entity.image.large.url, alt: alt_text)
  end

  # @param [PromoItem] entity
  def promo_image_medium(entity)
    return '' if entity.image.blank?

    versions = "#{entity.image.large.url} 2x"
    alt_text = entity.image_alt_text
    image_tag(entity.image.medium.url, alt: alt_text, srcset: versions)
  end

  # @param [PromoItem] entity
  def promo_image_preview(entity)
    return '' if entity.image.blank?

    versions = "#{entity.image.preview_2x.url} 2x"
    alt_text = entity.image_alt_text
    image_tag(entity.image.preview.url, alt: alt_text, srcset: versions)
  end
end
