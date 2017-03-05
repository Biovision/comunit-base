class Admin::NewsController < ApplicationController
  before_action :restrict_access
  before_action :set_entity, except: [:index]

  # get /admin/news
  def index
    @collection = News.page_for_administration current_page
  end

  # get /admin/news/:id
  def show
  end

  # get /admin/news/:id/news_categories
  def news_categories
    @collection = @entity.news_categories.page_for_administration
  end

  # get /admin/news/:id/post_categories
  def post_categories
    @collection = @entity.post_categories.page_for_administration
  end

  protected

  def restrict_access
    require_privilege_group :reporters
  end

  def set_entity
    @entity = News.find params[:id]
  end
end
