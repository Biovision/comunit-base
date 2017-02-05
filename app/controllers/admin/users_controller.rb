class Admin::UsersController < ApplicationController
  before_action :restrict_access
  before_action :set_entity, except: [:index]

  # get /admin/users
  def index
    @filter     = params[:filter] || Hash.new
    @collection = User.page_for_administration(current_page, @filter)
  end

  # get /admin/users/:id
  def show
  end

  # get /admin/users/:id/tokens
  def tokens
    @collection = Token.owned_by(@entity).page_for_administration(current_page)
  end

  # get /admin/users/:id/codes
  def codes
    @collection = Code.owned_by(@entity).page_for_administration(current_page)
  end

  # get /admin/users/:id/privileges
  def privileges
  end

  protected

  def restrict_access
    require_role :administrator
  end

  def set_entity
    @entity = User.find_by(id: params[:id], deleted: false)
    if @entity.nil?
      handle_http_404("Cannot find non-deleted user #{params[:id]}")
    end
  end
end