class Admin::PromoItemsController < AdminController
  include ToggleableEntity

  before_action :set_entity

  # get /admin/promo_items/:id
  def show
  end

  private

  def set_entity
    @entity = PromoItem.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404("Cannot find promo_item #{params[:id]}")
    end
  end
end
