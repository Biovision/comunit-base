class NewsCategoriesController < AdminController
  before_action :restrict_access
  before_action :set_entity, only: [:edit, :update, :destroy]
  before_action :restrict_editing, only: [:edit, :update, :destroy]

  # post /news_categories
  def create
    @entity = NewsCategory.new entity_parameters
    if @entity.save
      redirect_to admin_news_category_path(id: @entity.id)
    else
      render :new, status: :bad_request
    end
  end

  # get /news_categories/:id/edit
  def edit
  end

  # patch /news_categories/:id
  def update
    if @entity.update entity_parameters
      redirect_to admin_news_category_path(id: @entity.id), notice: t('news_categories.update.success')
    else
      render :edit, status: :bad_request
    end
  end

  # delete /news_categories/:id
  def destroy
    if @entity.update deleted: true
      flash[:notice] = t('news_categories.destroy.success')
    end
    redirect_to admin_news_categories_path
  end

  private

  def restrict_access
    require_privilege :administrator
  end

  def set_entity
    @entity = NewsCategory.find_by(id: params[:id], deleted: false)
    if @entity.nil?
      handle_http_404('Cannot find news category')
    end
  end

  def restrict_editing
    if @entity.locked?
      redirect_to admin_news_category_path(id: @entity.id), alert: t('news_categories.edit.forbidden')
    end
  end

  def entity_parameters
    params.require(:news_category).permit(NewsCategory.entity_parameters)
  end
end
