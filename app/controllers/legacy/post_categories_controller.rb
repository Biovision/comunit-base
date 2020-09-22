class Legacy::PostCategoriesController < AdminController
  before_action :set_entity, only: [:edit, :update, :destroy]
  before_action :restrict_editing, only: [:edit, :update, :destroy]

  # post /post_categories
  def create
    @entity = PostCategory.new creation_parameters
    if @entity.save
      cache_relatives
      redirect_to admin_post_category_path(id: @entity.id)
    else
      render :new, status: :bad_request
    end
  end

  # get /post_categories/:id/edit
  def edit
  end

  # patch /post_categories/:id
  def update
    if @entity.update entity_parameters
      cache_relatives
      redirect_to admin_post_category_path(id: @entity.id), notice: t('post_categories.update.success')
    else
      render :edit, status: :bad_request
    end
  end

  # delete /post_categories/:id
  def destroy
    if @entity.update deleted: true
      flash[:notice] = t('post_categories.destroy.success')
    end
    redirect_to admin_post_categories_path
  end

  private

  def set_entity
    @entity = PostCategory.find_by(id: params[:id], deleted: false)
    if @entity.nil?
      handle_http_404('Cannot find post category')
    end
  end

  def restrict_editing
    if @entity.locked?
      redirect_to admin_post_category_path(id: @entity.id), alert: t('post_categories.edit.forbidden')
    end
  end

  def entity_parameters
    params.require(:post_category).permit(PostCategory.entity_parameters)
  end

  def creation_parameters
    params.require(:post_category).permit(PostCategory.creation_parameters)
  end

  def cache_relatives
    @entity.cache_parents!
    unless @entity.parent.blank?
      parent = @entity.parent
      parent.cache_children!
      parent.save
    end
  end
end
