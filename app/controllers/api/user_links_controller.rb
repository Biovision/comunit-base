class Api::UserLinksController < ApplicationController
  before_action :restrict_anonymous_access, only: [:hide]
  before_action :set_entity

  def hide
    if @entity.followee == current_user
      @entity.update(visible: false)
      render json: { data: { visible: @entity.visible? } }
    else
      message = "User #{current_user.id} is not followee for link #{@entity.id}"
      handle_http_404(message)
    end
  end

  private

  def set_entity
    @entity = UserLink.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404("Cannot find user_link #{params[:id]}")
    end
  end
end
