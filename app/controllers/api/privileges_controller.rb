class Api::PrivilegesController < ApplicationController
  before_action :restrict_access
  before_action :set_entity

  private

  def set_entity
    @entity = Privilege.find_by(id: params[:id], deleted: false)
    if @entity.nil?
      handle_http_404('Cannot find non-deleted privilege')
    end
  end

  def restrict_access
    require_privilege :administrator
  end
end
