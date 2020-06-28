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
    # collect_main_news(current_page)
  end

  # get /regional_news
  def regional_news
    # collect_regional_news(current_page)
  end

  private

  def collect_main_news(page = 1)
    @main_news = []
    post_group = PostGroup['main-news']
    return if post_group.nil?

    categories = post_group.post_category_ids

    @main_news = Post.regional(current_region).with_category_ids(categories).page(page)
  end

  def collect_regional_news(page = 1)
    region         = Region.find_by(id: params[:region_id].to_s.to_i)
    @regional_news = Post.regional(region, current_region).where(post_type: PostType['news']).visible.recent.page(page).per(7)
  end
end
