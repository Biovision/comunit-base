class ThemesController < ApplicationController
  before_action :restrict_access
  before_action :set_entity, only: [:edit, :update, :destroy]
  before_action :restrict_editing, only: [:edit, :update, :destroy]

  # get /themes/new
  def new
    @entity = Theme.new
  end

  # post /themes
  def create
    @entity = Theme.new entity_parameters
    if @entity.save
      redirect_to admin_theme_path(@entity)
    else
      render :new, status: :bad_request
    end
  end

  # get /themes/:id/edit
  def edit
  end

  # patch /themes/:id
  def update
    if @entity.update entity_parameters
      redirect_to admin_theme_path(@entity), notice: t('themes.update.success')
    else
      render :edit, status: :bad_request
    end
  end

  # delete /themes/:id
  def destroy
    if @entity.destroy
      flash[:notice] = t('themes.destroy.success')
    end
    redirect_to admin_themes_path
  end

  protected

  def restrict_access
    require_privilege :administrator
  end

  def set_entity
    @entity = Theme.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find theme')
    end
  end

  def restrict_editing
    if @entity.locked?
      redirect_to admin_theme_path(@entity), alert: t('themes.edit.forbidden')
    end
  end

  def entity_parameters
    params.require(:theme).permit(Theme.entity_parameters)
  end
end
