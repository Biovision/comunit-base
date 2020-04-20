# frozen_string_literal: true

# Administrative part of deed category management
class Admin::DeedsController < AdminController
  include ToggleableEntity

  before_action :set_entity, except: :index

  # get /admin/deeds
  def index
    @collection = Deed.page_for_administration(current_page)
  end

  # get /admin/deeds/:id
  def show
  end

  private

  def component_class
    Biovision::Components::DeedsComponent
  end

  def set_entity
    @entity = Deed.find_by(id: params[:id])
    handle_http_404('Cannot find deed') if @entity.nil?
  end
end
