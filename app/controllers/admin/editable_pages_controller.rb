class Admin::EditablePagesController < ApplicationController
  before_action :restrict_access
  before_action :set_entity, except: [:index]

  # get /admin/editable_pages
  def index
    @collection = EditablePage.page_for_administration
  end

  # get /admin/editable_pages/:id
  def show
  end

  private

  def restrict_access
    require_role :chief_editor
  end

  def set_entity
    @entity = EditablePage.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404("Cannot find editable_page #{params[:id]}")
    end
  end
end