class PromoBlocksController < AdminController
  before_action :set_entity, only: [:edit, :update, :destroy]

  # post /promo_blocks/check
  def check
    @entity = PromoBlock.instance_for_check(params[:entity_id], entity_parameters)

    render 'shared/forms/check'
  end

  # get /promo_blocks/new
  def new
    @entity = PromoBlock.new
  end

  # post /promo_blocks
  def create
    @entity = PromoBlock.new(entity_parameters)
    if @entity.save
      form_processed_ok(admin_promo_block_path(id: @entity.id))
    else
      form_processed_with_error(:new)
    end
  end

  # get /promo_blocks/:id/edit
  def edit
  end

  # patch /promo_blocks/:id
  def update
    if @entity.update(entity_parameters)
      flash[:notice] = t('promo_blocks.update.success')
      form_processed_ok(admin_promo_block_path(id: @entity.id))
    else
      form_processed_with_error(:edit)
    end
  end

  # delete /promo_blocks/:id
  def destroy
    if @entity.destroy
      flash[:notice] = t('promo_blocks.destroy.success')
    end
    redirect_to(admin_promo_blocks_path)
  end

  protected

  def set_entity
    @entity = PromoBlock.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find promo_block')
    end
  end

  def entity_parameters
    params.require(:promo_block).permit(PromoBlock.entity_parameters)
  end
end
