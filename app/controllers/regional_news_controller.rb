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
    @entity   = News.find_by(slug: params[:slug], deleted: false)
    if @entity.nil? || !@entity.visible_to?(current_user)
      handle_http_404("Cannot show news #{params[:slug]} to user #{current_user&.id}")
    elsif @entity.news_category == @category
      @entity.increment! :view_count
    else
      parameters = { category_slug: @entity.news_category.slug, slug: @entity.slug }
      redirect_to news_in_category_regional_news_index_path(parameters)
    end
  end
end
