# frozen_string_literal: true

# Posts management
class PostsController < ApplicationController
  # get /posts
  def index
    excluded = param_from_request(:x).split(',').map(&:to_i)
    taxon_ids = params.key?(:taxon_id) ? Array(params[:taxon_id]) : []
    @collection = Post.exclude_ids(excluded).with_taxon_ids(taxon_ids).page_for_visitors(current_page)
  end

  def news
    redirect_to posts_path
  end

  def articles
    redirect_to posts_path
  end

  def blog
    redirect_to posts_path
  end

  # get /posts/:id(-:slug)
  def show
    @entity = Post.list_for_visitors.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404("Cannot find non-deleted post #{params[:id]}")
    else
      @entity.increment :view_count
      @entity.increment :rating, 0.0025
      @entity.save
    end
  end

  def legacy_show
    @entity = Post.list_for_visitors.find_by(slug: params[:slug])
    if @entity.nil?
      handle_http_404("Cannot find non-deleted post #{params[:id]}")
    else
      @entity.increment :view_count
      @entity.increment :rating, 0.0025
      @entity.save

      render :show
    end
  end

  # get /posts/tagged/:tag_name
  def tagged
    redirect_to posts_path
  end

  # get /posts/:category_slug
  def category
    posts = Post.in_category(params[:category_slug])
    @collection = posts.page_for_visitors(current_page)
    @category = @collection.first&.post_category

    handle_http_404('Cannot find post category in collection') if @category.nil?

    respond_to do |format|
      format.html
      format.json { render('posts/index') }
    end
  end

  # get /posts/search?q=
  def search
    @collection = params.key?(:q) ? search_posts(param_from_request(:q)) : []
  end

  # get /posts/rss/zen.xml
  def zen
    posts = Post.list_for_visitors
    @collection = posts.posted_after(3.days.ago)
  end

  # get /posts/rss.xml
  def rss
    posts = Post.list_for_visitors
    @collection = posts.first(20)
  end

  # get /posts/archive/(:year)(-:month)(-:day)
  def archive
    if params.key?(:day)
      archive_day
    else
      collect_dates
    end
  end

  private

  def component_class
    Biovision::Components::PostsComponent
  end

  def collect_dates
    array = Post.visible.published.archive
    @dates = Post.archive_dates(array)
  end

  def archive_day
    date = Date.parse("#{params[:year]}-#{params[:month]}-#{params[:day]}")
    selection = Post.pubdate(date)
    @collection = selection.page_for_visitors(current_page)
    render 'archive_day'
  end

  # @param [String] q
  def search_posts(q)
    Post.search(q).list_for_visitors.first(50)
  end
end
