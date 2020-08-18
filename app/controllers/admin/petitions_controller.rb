# frozen_string_literal: true

# Administrative part of handling petitions
class Admin::PetitionsController < AdminController
  include ToggleableEntity

  before_action :set_entity, except: :index

  # get /admin/petitions
  def index
    @collection = Petition.page_for_administration(current_page)
  end

  # get /admin/petitions/:id
  def show
  end

  # get /admin/petitions/:id/signs
  def signs
    @collection = @entity.petition_signs.list_for_administration
  end

  private

  def component_class
    Biovision::Components::PetitionsComponent
  end

  def set_entity
    @entity = Petition.find_by(id: params[:id])
    handle_http_404('Cannot find petition') if @entity.nil?
  end
end
