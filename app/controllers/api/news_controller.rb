class Api::NewsController < ApplicationController
  before_action :restrict_access
  before_action :set_entity, only: [:toggle, :lock, :unlock, :category]

  # post /api/news/:id/toggle
  def toggle
    if @entity.locked?
      render json: { errors: { locked: @entity.locked } }, status: :forbidden
    else
      render json: { data: @entity.toggle_parameter(params[:parameter].to_s) }
    end
  end

  # put /api/news/:id/lock
  def lock
    @entity.update! locked: true

    render json: { data: { locked: @entity.locked? } }
  end

  # delete /api/news/:id/lock
  def unlock
    @entity.update! locked: false

    render json: { data: { locked: @entity.locked? } }
  end

  # put /api/news/:id/category
  def category
    if params[:category_id].to_s.to_i > 0
      @entity.news_category = NewsCategory.find params[:category_id].to_s.to_i
    else
      @entity.site_news.destroy_all
    end

    head :no_content
  end

  private

  def set_entity
    @entity = News.find params[:id]
    raise record_not_found if @entity.deleted?
  end

  def restrict_access
    require_role :administrator
  end
end
