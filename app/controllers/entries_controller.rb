class EntriesController < ApplicationController
  layout 'blog'

  before_action :restrict_anonymous_access, except: [:index, :show]
  before_action :restrict_adding, only: [:new, :create]
  before_action :set_entity, except: [:index, :new, :create, :archive]
  before_action :restrict_editing, only: [:edit, :update, :destroy]
  before_action :restrict_reposting, only: [:new_repost, :create_repost]

  # get /entries
  def index
    @collection = Entry.page_for_visitors(current_user, current_page)
  end

  # get /entries/new
  def new
    @entity = Entry.new
  end

  # post /entries
  def create
    @entity = Entry.new creation_parameters
    if @entity.save
      redirect_to @entity
    else
      render :new, status: :bad_request
    end
  end

  # get /entries/:id
  def show
    @entity.increment! :view_count
    set_adjacent_entities
  end

  # get /entries/:id/edit
  def edit
  end

  # patch /entries/:id
  def update
    if @entity.update entity_parameters
      redirect_to @entity, notice: t('entries.update.success')
    else
      render :edit, status: :bad_request
    end
  end

  # delete /entries/:id
  def destroy
    if @entity.update(deleted: true)
      flash[:notice] = t('entries.destroy.success')
    end

    redirect_to entries_path
  end

  # get /entries/archive/(:year)/(:month)
  def archive
    collect_months
    unless params[:month].nil?
      @collection = Entry.archive(params[:year], params[:month]).page_for_visitors current_user, current_page
    end
  end

  # get /entries/:id/reposts/new
  def new_repost
    @news = @entity.news.new
  end

  # post /entries/:id/reposts
  def create_repost
    @news = @entity.news.new(repost_parameters)
    if @news.save
      redirect_to @news
    else
      render :new_repost, status: :bad_request
    end
  end

  private

  def set_entity
    @entity = Entry.find_by(id: params[:id], deleted: false)
    if @entity.nil?
      handle_http_404('Cannot find non-deleted entry')
    end
    unless @entity.visible_to?(current_user)
      handle_http_401("Entity is not visible to user #{current_user&.id}")
    end
  end

  def restrict_editing
    raise record_not_found unless @entity.editable_by? current_user
  end

  def creation_parameters
    entry_parameters = params.require(:entry).permit(Entry.creation_parameters)
    entry_parameters.merge(owner_for_entity(true))
  end

  def entity_parameters
    params.require(:entry).permit(Entry.entity_parameters)
  end

  def collect_months
    @dates = Hash.new
    Entry.not_deleted.distinct.pluck("date_trunc('month', created_at)").sort.each do |date|
      @dates[date.year] = [] unless @dates.has_key? date.year
      @dates[date.year] << date.month
    end
  end

  def set_adjacent_entities
    privacy   = Entry.privacy_for_user(current_user)
    @adjacent = {
        prev: Entry.with_privacy(privacy).where('id < ?', @entity.id).order('id desc').first,
        next: Entry.with_privacy(privacy).where('id > ?', @entity.id).order('id asc').first
    }
  end

  def restrict_adding
    unless current_user.verified?
      redirect_to entries_path, alert: t('entries.new.restricted')
    end
  end

  def restrict_reposting
    unless @entity.generally_accessible?
      redirect_to @entity, alert: t('entries.new_repost.forbidden')
    end
  end

  def repost_parameters
    entry_parameters = {
        body: 'repost',
        title: @entity.title.blank? ? t(:untitled) : @entity.title
    }
    post_parameters = params.require(:news).permit(News.repost_parameters)
    post_parameters.merge(owner_for_entity(true)).merge(entry_parameters)
  end
end
