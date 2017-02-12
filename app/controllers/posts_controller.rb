class PostsController < ApplicationController
  before_action :restrict_access, only: [:new, :create]
  before_action :set_entity, only: [:edit, :update, :destroy]
  before_action :restrict_editing, only: [:edit, :update, :destroy]

  # get /posts
  def index
    @collection = Post.page_for_visitors current_page
  end

  # get /posts/:category_slug
  def category
    @category   = PostCategory.find_by! slug: params[:category_slug]
    @collection = Post.in_category(@category).page_for_visitors(current_page)
  end

  # get /posts/new
  def new
    @entity = Post.new
  end

  # post /posts
  def create
    @entity = Post.new creation_parameters
    if @entity.save
      # set_dependent_entities
      redirect_to admin_post_path(@entity)
    else
      render :new, status: :bad_request
    end
  end

  # get /posts/:id
  def show
    @entity = Post.find_by(id: params[:id], deleted: false)
    if @entity.nil?
      handle_http_404("Cannot find non-deleted post #{params[:id]}")
    else
      redirect_to post_in_category_posts_path(category_slug: @entity.post_category.slug, slug: @entity.slug)
    end
  end

  # get /posts/:category_slug/:slug
  # get /publikacii/:category_slug/:slug
  def show_in_category
    @category = PostCategory.find_by! slug: params[:category_slug]
    @entity = Post.find_by! slug: params[:slug]
    raise record_not_found unless @entity.visible_to?(current_user) && @category.has_post?(@entity)
    @entity.increment! :view_count
  end

  # get /posts/:id/edit
  def edit
  end

  # patch /posts/:id
  def update
    if @entity.update entity_parameters
      # set_dependent_entities
      redirect_to admin_post_path(@entity), notice: t('posts.update.success')
    else
      render :edit, status: :bad_request
    end
  end

  # delete /posts/:id
  def destroy
    if @entity.update(deleted: true)
      flash[:notice] = t('posts.destroy.success')
    end
    redirect_to admin_posts_path
  end

  # get /posts/archive/(:year)/(:month)
  def archive
    collect_months
    @collection = Post.archive(params[:year], params[:month]).page_for_visitors current_page unless params[:month].nil?
  end

  private

  def set_entity
    @entity = Post.find_by(id: params[:id], deleted: false)
    if @entity.nil?
      handle_http_404('Cannot find post')
    end
  end

  def collect_months
    @dates = Hash.new
    Post.visible.distinct.pluck("date_trunc('month', created_at)").sort.each do |date|
      @dates[date.year] = [] unless @dates.has_key? date.year
      @dates[date.year] << date.month
    end
  end

  def restrict_access
    require_role :chief_editor, :post_editor
  end

  def restrict_editing
    unless @entity.editable_by? current_user
      handle_http_401("Post is not editable by user #{current_user&.id}")
    end
  end

  def entity_parameters
    params.require(:post).permit(Post.entity_parameters)
  end

  def creation_parameters
    entity_parameters.merge(owner_for_entity(true))
  end

  def set_dependent_entities
    add_figures unless params[:figures].blank?
  end

  def add_figures
    params[:figures].values.reject { |f| f[:slug].blank? || f[:image].blank? }.each do |data|
      @entity.figures.create(data.select { |key, _| Figure.creation_parameters.include? key })
    end
  end
end
