class Admin::PromoBlocksController < AdminController
  include ToggleableEntity

  before_action :set_entity, except: [:index]

  # get /admin/promo_blocks
  def index
    @collection = PromoBlock.list_for_administration
  end

  # get /admin/promo_blocks/:id
  def show
  end

  private

  def restrict_access
    require_privilege :promo_manager
  end

  def set_entity
    @entity = PromoBlock.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404("Cannot find promo_block #{params[:id]}")
    end
  end
end
