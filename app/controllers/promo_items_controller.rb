class PromoItemsController < AdminController
  before_action :set_entity, only: [:edit, :update, :destroy]

  # post /promo_items/check
  def check
    @entity = PromoItem.instance_for_check(params[:entity_id], entity_parameters)

    render 'shared/forms/check'
  end

  # get /promo_items/new
  def new
    @entity = PromoItem.new
  end

  # post /promo_items
  def create
    @entity = PromoItem.new(creation_parameters)
    if @entity.save
      form_processed_ok(admin_promo_item_path(id: @entity.id))
    else
      form_processed_with_error(:new)
    end
  end

  # get /promo_items/:id/edit
  def edit
  end

  # patch /promo_items/:id
  def update
    if @entity.update(entity_parameters)
      flash[:notice] = t('promo_items.update.success')
      form_processed_ok(admin_promo_item_path(id: @entity.id))
    else
      form_processed_with_error(:edit)
    end
  end

  # delete /promo_items/:id
  def destroy
    if @entity.destroy
      flash[:notice] = t('promo_items.destroy.success')
    end
    redirect_to(admin_promo_block_path(id: @entity.promo_block_id))
  end

  protected

  def restrict_access
    require_privilege :promo_manager
  end

  def set_entity
    @entity = PromoItem.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find promo_item')
    end
  end

  def entity_parameters
    params.require(:promo_item).permit(PromoItem.entity_parameters)
  end

  def creation_parameters
    entity_parameters.merge(owner_for_entity(true))
  end
end
