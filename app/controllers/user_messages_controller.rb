class UserMessagesController < ApplicationController
  before_action :restrict_anonymous_access
  before_action :set_entity, except: [:create]

  # post /user_messages
  def create
    @entity = UserMessage.new(creation_parameters)
    if @entity.save
      notify_receiver
      redirect_to dialog_my_messages_path(user_slug: @entity.receiver.long_slug)
    else
      render :new, status: :bad_request
    end
  end

  # delete /user_messages/:id
  def destroy
    other_user_slug = @entity.destroy_by_user(current_user)
    redirect_to dialog_my_messages_path(user_slug: other_user_slug)
  end

  private

  def set_entity
    @entity = UserMessage.find_by(id: params[:id])
    if @entity.nil? || !@entity.visible_to?(current_user)
      logger.warn "User #{current_user.id} tries to reach message: #{params.inspect}"
      render :not_found, status: :not_found
    end
  end

  def creation_parameters
    part = params.require(:user_message).permit(UserMessage.creation_parameters)
    part.merge({ sender: current_user }).merge(tracking_for_entity)
  end

  def notify_receiver
    category = Notification.category_from_object(@entity)
    Notification.notify(@entity.receiver, category, @entity.sender_id)
  end
end
