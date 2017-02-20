class Api::PostsController < ApplicationController
  before_action :restrict_access
  before_action :set_entity
  before_action :restrict_locking, only: [:lock, :unlock]

  # post /api/posts/:id/toggle
  def toggle
    if @entity.locked?
      render json: { errors: { locked: @entity.locked } }, status: :locked
    else
      render json: { data: @entity.toggle_parameter(params[:parameter].to_s) }
    end
  end

  # put /api/posts/:id/lock
  def lock
    @entity.update! locked: true

    render json: { data: { locked: @entity.locked? } }
  end

  # delete /api/posts/:id/lock
  def unlock
    @entity.update! locked: false

    render json: { data: { locked: @entity.locked? } }
  end

  # put /api/posts/:id/category
  def category
    if params[:category_id].to_s.to_i > 0
      @entity.post_category = PostCategory.find params[:category_id].to_s.to_i
    else
      @entity.site_posts.destroy_all
    end

    head :no_content
  end

  private

  def set_entity
    @entity = Post.find_by(id: params[:id], deleted: false)
    if @entity.nil?
      handle_http_404('Cannot find non-deleted post')
    end
  end

  def restrict_access
    require_privilege_group :editors
  end

  def restrict_locking
    require_privilege :central_chief_editor
  end
end
