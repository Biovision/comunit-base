class Admin::NewsCategoriesController < ApplicationController
  before_action :restrict_access
  before_action :set_entity, except: [:index]

  def index
    @collection = NewsCategory.page_for_administration
  end

  # get /admin/news_categories/:id
  def show
  end

  # get /admin/news_categories/:id/items
  def items
    @collection = News.in_category(@entity).page_for_administration current_page
  end

  protected

  def restrict_access
    require_role :administrator
  end

  def set_entity
    @entity = NewsCategory.find params[:id]
    raise record_not_found if @entity.deleted?
  end
end
