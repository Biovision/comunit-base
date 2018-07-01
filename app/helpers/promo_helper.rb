module PromoHelper
  # @param [PromoBlock] entity
  def admin_promo_block_link(entity)
    text = entity.name.blank? ? entity.slug : entity.name
    link_to(text, admin_promo_block_path(id: entity.id))
  end

  # @param [PromoItem] entity
  def admin_promo_item_link(entity)
    link_to(entity.text_for_link, admin_promo_item_path(id: entity.id))
  end

  # @param [LinkBlock] entity
  def promo_image(entity)
    return '' if entity.image.blank?
    image_tag(entity.image.url, alt: entity.image_alt_text)
  end
end
