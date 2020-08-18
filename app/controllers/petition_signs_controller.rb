# frozen_string_literal: true

# Handling petition signs
class PetitionSignsController < ApplicationController
  before_action :restrict_access, except: %i[check create]
  before_action :set_entity, except: %i[check index new create]

  # post /petition_signs/check
  def check
    @entity = PetitionSign.instance_for_check(params[:entity_id], entity_parameters)

    render 'shared/forms/check'
  end

  # post /petition_signs
  def create
    @entity = PetitionSign.new(creation_parameters)
    if @entity.save
      Comunit::Network::Handler.sync(@entity)
      form_processed_ok(petition_path(id: @entity.petition_id))
    else
      form_processed_with_error(:new)
    end
  end

  # delete /petition_signs/:id
  def destroy
    flash[:notice] = t('.success') if @entity.destroy
    redirect_to(admin_petition_path(id: @entity.petition_id))
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
    @entity = PetitionSign.find_by(id: params[:id])
    handle_http_404('Cannot find petition') if @entity.nil?
  end

  def entity_parameters
    params.require(:petition_sign).permit(PetitionSign.entity_parameters)
  end

  def creation_parameters
    permitted = PetitionSign.creation_parameters
    parameters = params.require(:petition_sign).permit(permitted)
    parameters.merge(owner_for_entity(true))
  end
end
