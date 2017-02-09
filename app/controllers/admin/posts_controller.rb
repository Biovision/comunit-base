class Admin::PostsController < ApplicationController
  before_action :restrict_access
  before_action :set_entity, except: [:index]

  # get /admin/posts
  def index
    @collection = Post.page_for_administration current_page
  end

  # get /admin/posts/:id
  def show
  end

  # get /admin/posts/:id/post_categories
  def post_categories
    @collection = @entity.post_categories.page_for_administration
  end

  private

  def restrict_access
    require_role :chief_editor, :post_editor
  end

  def set_entity
    @entity = Post.find params[:id]
  end
end
