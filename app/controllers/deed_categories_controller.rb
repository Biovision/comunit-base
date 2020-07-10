# frozen_string_literal: true

# Managing deed categories
class DeedCategoriesController < AdminController
  before_action :set_entity, only: %i[edit update destroy]

  # post /deed_categories/check
  def check
    @entity = DeedCategory.instance_for_check(params[:entity_id], entity_parameters)

    render 'shared/forms/check'
  end

  # get /deed_categories/new
  def new
    @entity = DeedCategory.new
  end

  # post /deed_categories
  def create
    @entity = DeedCategory.new(creation_parameters)
    if @entity.save
      NetworkEntitySyncJob.perform_later(@entity.class.to_s, @entity.id)
      form_processed_ok(admin_deed_category_path(id: @entity.id))
    else
      form_processed_with_error(:new)
    end
  end

  # get /deed_categories/:id/edit
  def edit
  end

  # patch /deed_categories/:id
  def update
    if @entity.update(entity_parameters)
      NetworkEntitySyncJob.perform_later(@entity.class.to_s, @entity.id)
      form_processed_ok(admin_deed_category_path(id: @entity.id))
    else
      form_processed_with_error(:edit)
    end
  end

  # delete /deed_categories/:id
  def destroy
    flash[:notice] = t('.success') if @entity.destroy
    redirect_to(admin_deed_categories_path)
  end

  protected

  def component_class
    Biovision::Components::DeedsComponent
  end

  def set_entity
    @entity = DeedCategory.find_by(id: params[:id])
    handle_http_404('Cannot find deed_category') if @entity.nil?
  end

  def creation_parameters
    params.require(:deed_category).permit(DeedCategory.creation_parameters)
  end

  def entity_parameters
    params.require(:deed_category).permit(DeedCategory.entity_parameters)
  end
end
