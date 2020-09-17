# frozen_string_literal: true

# Handling post groups
class TaxonsController < AdminController
  before_action :set_entity, only: %i[edit update destroy]

  # post /taxons/check
  def check
    @entity = Taxon.instance_for_check(params[:entity_id], entity_parameters)

    render 'shared/forms/check'
  end

  # get /taxons/new
  def new
    @entity = Taxon.new
  end

  # post /taxons
  def create
    @entity = Taxon.new(entity_parameters)
    if @entity.save
      form_processed_ok(admin_taxon_path(id: @entity.id))
    else
      form_processed_with_error(:new)
    end
  end

  # get /taxons/:id/edit
  def edit
  end

  # patch /taxons/:id
  def update
    if @entity.update(entity_parameters)
      form_processed_ok(admin_taxon_path(id: @entity.id))
    else
      form_processed_with_error(:edit)
    end
  end

  # delete /taxons/:id
  def destroy
    flash[:notice] = t('.success') if @entity.destroy

    redirect_to admin_taxons_path(id: @entity.id)
  end

  private

  def component_class
    Biovision::Components::PostsComponent
  end

  def restrict_access
    error = 'Managing taxons is not allowed'
    handle_http_401(error) unless component_handler.allow?('chief_editor')
  end

  def set_entity
    @entity = Taxon.find_by(id: params[:id])
    handle_http_404('Cannot find taxon') if @entity.nil?
  end

  def entity_parameters
    params.require(:taxon).permit(Taxon.entity_parameters)
  end
end
