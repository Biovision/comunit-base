# frozen_string_literal: true

# Front part for managing countries
class CountriesController < AdminController
  before_action :set_entity, except: %i[new create]

  # get /countries/new
  def new
    @entity = Country.new
  end

  # post /regions
  def create
    @entity = Country.new(creation_parameters)
    if @entity.save
      form_processed_ok(admin_region_path(id: @entity.id))
    else
      form_processed_with_error(:new)
    end
  end

  # get /countries/:id/edit
  def edit
  end

  # patch /countries/:id
  def update
    if @entity.update(entity_parameters)
      form_processed_ok(admin_region_path(id: @entity.id))
    else
      form_processed_with_error(:edit)
    end
  end

  # delete /countries/:id
  def destroy
    if @entity.can_be_deleted? && @entity.destroy
      flash[:notice] = t('countries.destroy.success')
    end
    redirect_to admin_countries_path
  end

  protected

  def component_class
    Biovision::Components::RegionsComponent
  end

  def set_entity
    @entity = Country.find_by(id: params[:id])
    handle_http_404('Cannot find country') if @entity.nil?
  end

  def entity_parameters
    params.require(:region).permit(Country.entity_parameters)
  end

  def creation_parameters
    params.require(:region).permit(Country.creation_parameters)
  end
end
