class NewsController < ApplicationController
  before_action :restrict_access, only: [:new, :create]
  before_action :set_entity, only: [:edit, :update, :destroy]
  before_action :restrict_editing, only: [:edit, :update, :destroy]

  # get /news
  # get /novosti
  def index
    @collection = News.federal.page_for_visitors current_page
  end

  # get /news/:category_slug
  # get /novosti/:category_slug
  def category
    @category   = NewsCategory.find_by! slug: params[:category_slug]
    @collection = News.of_type(:news).in_category(@category).page_for_visitors(current_page)
  end

  # get /news/new
  def new
    @entity = News.new
  end

  # post /news
  def create
    @entity = News.new creation_parameters
    if @entity.save
      # add_figures unless params[:figures].blank?
      redirect_to admin_news_path(@entity)
    else
      render :new, status: :bad_request
    end
  end

  # get /news/:id
  def show
    @entity = News.find_by(id: params[:id], deleted: false)
    if @entity.nil?
      handle_http_404("Cannot find non-deleted news #{params[:id]}")
    else
      category_slug = @entity.news_category.slug
      if @entity.regional?
        redirect_to news_in_category_regional_news_index_path(category_slug: category_slug, slug: @entity.slug)
      else
        redirect_to news_in_category_news_index_path(category_slug: category_slug, slug: @entity.slug)
      end
    end
  end

  # get /news/:category_slug/:slug
  # get /novosti/:category_slug/:slug
  def show_in_category
    @category = NewsCategory.find_by(slug: params[:category_slug])
    @entity   = News.find_by(slug: params[:slug], deleted: false)
    if @entity.nil? || !@entity.visible_to?(current_user)
      handle_http_404("Cannot show news #{params[:slug]} to user #{current_user&.id}")
    elsif @entity.news_category == @category
      @entity.increment! :view_count
    else
      parameters = { category_slug: @entity.news_category.slug, slug: @entity.slug }
      redirect_to news_in_category_news_index_path(parameters)
    end
  end

  # get /news/:id/edit
  def edit
  end

  # patch /news/:id
  def update
    if @entity.update entity_parameters
      # add_figures unless params[:figures].blank?
      redirect_to admin_news_path(@entity), notice: t('news.update.success')
    else
      render :edit, status: :bad_request
    end
  end

  # delete /news/:id
  def destroy
    if @entity.update(deleted: true)
      flash[:notice] = t('news.destroy.success')
    end
    redirect_to admin_news_index_path
  end

  private

  def set_entity
    @entity = News.find params[:id]
  end

  def restrict_access
    require_privilege_group :reporters
  end

  def restrict_editing
    raise record_not_found unless @entity.editable_by? current_user
  end

  def entity_parameters
    params.require(:news).permit(News.entity_parameters)
  end

  def creation_parameters
    entity_parameters.merge(owner_for_entity(true))
  end

  def add_figures
    params[:figures].values.reject { |f| f[:slug].blank? || f[:image].blank? }.each do |data|
      @entity.figures.create!(data.select { |key, _| Figure.creation_parameters.include? key.to_sym })
    end
  end
end
