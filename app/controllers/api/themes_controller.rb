class Api::ThemesController < ApplicationController
  before_action :restrict_access
  before_action :set_entity

  # put /api/themes/:id/lock
  def lock
    @entity.update! locked: true

    render json: { data: { locked: @entity.locked? } }
  end

  # delete /api/themes/:id/lock
  def unlock
    @entity.update! locked: false

    render json: { data: { locked: @entity.locked? } }
  end

  # put /api/themes/:id/post_categories/:category_id
  def add_post_category
    ids = (@entity.post_category_ids + [params[:category_id].to_i]).uniq

    @entity.post_category_ids = ids
    render json: { data: { ids: ids } }
  end

  # delete /api/themes/:id/post_categories/:category_id
  def remove_post_category
    ids = @entity.post_category_ids - [params[:category_id].to_i]

    @entity.post_category_ids = ids
    render json: { data: { ids: ids } }
  end

  # put /api/themes/:id/news_categories/:category_id
  def add_news_category
    ids = (@entity.news_category_ids + [params[:category_id]]).uniq

    @entity.news_category_ids = ids
    render json: { data: { ids: ids } }
  end

  # delete /api/themes/:id/news_categories/:category_id
  def remove_news_category
    ids = @entity.news_category_ids - [params[:category_id]]

    @entity.news_category_ids = ids
    render json: { data: { ids: ids } }
  end

  private

  def set_entity
    @entity = Theme.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find theme')
    end
  end

  def restrict_access
    require_role :administrator
  end
end
