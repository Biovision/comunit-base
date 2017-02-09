class RegionalNewsController < ApplicationController
  # get /regional_news
  def index
    @collection = News.regional.page_for_visitors current_page
  end

  # get /regional_news/:category_slug
  def category
    @category   = NewsCategory.find_by! slug: params[:category_slug]
    @collection = News.of_type(:news).in_category(@category).page_for_visitors(current_page)
  end

  # get /regional_news/:category_slug/:slug
  def show_in_category
    @category = NewsCategory.find_by(slug: params[:category_slug])
    if @category.nil?
      handle_http_404("Cannot find news category #{params[:category_slug]}")
    else
      @entity = News.find_by(slug: params[:slug], deleted: false)
      if @entity.nil? || !@entity.visible_to?(current_user) || !@category.has_news?(@entity)
        handle_http_404("Cannot show news #{params[:slug]} to user #{current_user&.id}")
      else
        @entity.increment! :view_count
      end
    end
  end
end
