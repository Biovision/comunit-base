class Admin::RegionsController < ApplicationController
  before_action :restrict_access
  before_action :set_entity, except: [:index]

  # get /admin/regions
  def index
    @collection = Region.page_for_administration
  end

  # get /admin/regions/:id
  def show
  end

  # get /admin/regions/:id/cities
  def cities
    @collection = @entity.cities.page_for_administration
  end

  private

  def restrict_access
    require_role :administrator
  end

  def set_entity
    @entity = Region.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404("Cannot find non-deleted region #{params[:id]}")
    end
  end
end
