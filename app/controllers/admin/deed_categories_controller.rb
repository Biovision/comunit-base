# frozen_string_literal: true

# Administrative part of deed category management
class Admin::DeedCategoriesController < AdminController
  include EntityPriority
  include ToggleableEntity

  before_action :set_entity, except: :index
  before_action :set_deed, only: %i[add_deed remove_deed]

  # get /admin/deed_categories
  def index
    @collection = DeedCategory.siblings(nil).list_for_administration
  end

  # get /admin/deed_categories/:id
  def show
  end

  # put /admin/deed_categories/:id/deeds/:deed_id
  def add_deed
    @entity.add_deed(@deed)
    NetworkEntitySyncJob.perform_later(@deed.class.to_s, @deed.id)

    head :no_content
  end

  # delete /admin/deed_categories/:id/deeds/:deed_id
  def remove_deed
    @entity.remove_deed(@deed)
    NetworkEntitySyncJob.perform_later(@deed.class.to_s, @deed.id)

    head :no_content
  end

  private

  def component_class
    Biovision::Components::DeedsComponent
  end

  def set_entity
    @entity = DeedCategory.find_by(id: params[:id])
    handle_http_404('Cannot find deed_category') if @entity.nil?
  end

  def set_deed
    @deed = Deed.find_by(id: params[:deed_id])
    handle_http_404('Cannot find deed') if @deed.nil?
  end
end
