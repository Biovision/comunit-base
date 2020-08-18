# frozen_string_literal: true

# Handling petitions
class PetitionsController < ApplicationController
  before_action :restrict_access, except: %i[index show results answer]
  before_action :set_entity, except: %i[check index new create]

  layout 'admin', except: %i[index show signs]

  # post /petitions/check
  def check
    @entity = Petition.instance_for_check(params[:entity_id], entity_parameters)

    render 'shared/forms/check'
  end

  # get /petitions
  def index
    @collection = Petition.page_for_visitors(current_page)
  end

  # get /petitions/new
  def new
    @entity = Petition.new
  end

  # post /petitions
  def create
    @entity = Petition.new(creation_parameters)
    if @entity.save
      Comunit::Network::Handler.sync(@entity)
      form_processed_ok(petition_path(id: @entity.id))
    else
      form_processed_with_error(:new)
    end
  end

  # get /petitions/:id
  def show
  end

  # get /petitions/:id/edit
  def edit
  end

  # patch /petitions/:id
  def update
    if @entity.update(entity_parameters)
      Comunit::Network::Handler.sync(@entity)
      form_processed_ok(admin_petition_path(id: @entity.id))
    else
      form_processed_with_error(:edit)
    end
  end

  # delete /petitions/:id
  def destroy
    flash[:notice] = t('.success') if @entity.destroy
    redirect_to(admin_petitions_path)
  end

  # get /petitions/:id/signs
  def signs
    @collection = @entity.petition_signs.page_for_visitors(current_page)
  end

  protected

  def component_class
    Biovision::Components::PetitionsComponent
  end

  def restrict_access
    error = 'Managing petitions is not allowed for current user'
    handle_http_401(error) unless component_handler.allow?
  end

  def set_entity
    @entity = Petition.find_by(id: params[:id])
    handle_http_404('Cannot find petition') if @entity.nil?
  end

  def entity_parameters
    params.require(:petition).permit(Petition.entity_parameters)
  end

  def creation_parameters
    entity_parameters.merge(owner_for_entity(true))
  end
end
