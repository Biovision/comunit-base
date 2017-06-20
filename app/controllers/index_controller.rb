class IndexController < ApplicationController
  # get /
  def index
    collect_main_news
    collect_regional_news
  end

  # get /r/:region_slug
  def regional
    collect_main_news
    collect_regional_news

    render :index
  end

  # get /main_news
  def main_news
    collect_main_news(current_page)
  end

  # get /regional_news
  def regional_news
    collect_regional_news(current_page)
  end

  private

  def collect_main_news(page = 1)
    @main_news = Theme.where(slug: 'main-news').first&.entries(7, current_region, page)
  end

  def collect_regional_news(page = 1)
    @regional_news = News.regional(params[:region_id].to_s.to_i, current_region).visible.recent.page(page).per(7)
  end
end
