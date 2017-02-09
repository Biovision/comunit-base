class Admin::ThemesController < ApplicationController
  before_action :restrict_access
  before_action :set_entity, except: [:index]

  # get /admin/themes
  def index
    @collection = Theme.page_for_administration
  end

  # get /admin/themes/:id
  def show
  end

  private

  def restrict_access
    require_role :administrator
  end

  def set_entity
    @entity = Theme.find params[:id]
  end
end
