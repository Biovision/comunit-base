# frozen_string_literal: true

# Management of deeds
class DeedsController < ApplicationController
  before_action :restrict_anonymous_access, only: %i[new create]
  before_action :set_entity, only: %i[edit show update destroy]

  # post /deeds/check
  def check
    @entity = Deed.instance_for_check(params[:entity_id], entity_parameters)

    render 'shared/forms/check'
  end

  # get /deeds/regions
  def regions
    @collection = Region.visible.for_tree(nil, params[:parent_id])
  end

  # get /deeds
  def index
    # @collection = Deed.page_for_visitors(current_page)
  end

  # get /deeds/new
  def new
    @entity = Deed.new
  end

  # post /deeds
  def create
    @entity = Deed.new(creation_parameters)
    if @entity.save
      apply_categories if params.key?(:category)
      NetworkEntitySyncJob.perform_later(@entity.class.to_s, @entity.id)
      form_processed_ok(deed_path(id: @entity.id))
    else
      form_processed_with_error(:new)
    end
  end

  # get /deeds/:id
  def show
    @entity.increment! :view_count
  end

  # get /deeds/:id/edit
  def edit
  end

  # patch /deeds/:id
  def update
    if @entity.update(entity_parameters)
      apply_categories if params.key?(:category)
      NetworkEntitySyncJob.perform_later(@entity.class.to_s, @entity.id)
      form_processed_ok(deed_path(id: @entity.id))
    else
      form_processed_with_error(:edit)
    end
  end

  # delete /deeds/:id
  def destroy
    flash[:notice] = t('deeds.destroy.success') if @entity.destroy
    redirect_to(admin_deeds_path)
  end

  protected

  def component_class
    Biovision::Components::DeedsComponent
  end

  def restrict_editing
    error = 'Entity is not editable by current user'
    handle_http_401(error) unless component_handler.editable?(@entity)
  end

  def set_entity
    @entity = Deed.list_for_visitors.find_by(id: params[:id])
    handle_http_404('Cannot find deed') if @entity.nil?
  end

  def entity_parameters
    params.require(:deed).permit(Deed.entity_parameters)
  end

  def creation_parameters
    entity_parameters.merge(owner_for_entity(true))
  end

  def apply_categories
    @entity.deed_category_ids = Array(params[:category])
  end
end
