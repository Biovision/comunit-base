class ArticlesController < ApplicationController
  before_action :set_category, only: :category
  before_action :set_entity, only: :show

  # get /articles
  def index
    post_type   = PostType.find_by(slug: 'article')
    @collection = post_type.posts.page_for_visitors(current_page)
    respond_to do |format|
      format.html
      format.json { render('posts/index') }
    end
  end

  # get /articles/:category_slug
  def category
    @collection = Post.in_category_branch(@category).page_for_visitors(current_page)
    respond_to do |format|
      format.html
      format.json { render('posts/index') }
    end
  end

  # get /articles/:post_id-:post_slug
  def show
    @entity.increment :view_count
    @entity.increment :rating, 0.0025
    @entity.save
  end

  # get /articles/tagged/:tag_name
  def tagged
    post_type   = PostType.find_by(slug: 'article')
    @collection = post_type.posts.tagged(params[:tag_name]).page_for_visitors(current_page)
  end

  private

  def set_category
    type      = PostType.find_by(slug: 'article')
    @category = type.post_categories.for_current_site.find_by(long_slug: params[:category_slug])
    handle_http_404('Cannot find post category (article)') if @category.nil?
  end

  def set_entity
    @entity = Post.list_for_visitors.find_by(id: params[:post_id])
    handle_http_404('Cannot find article') if @entity.nil?
  end
end
