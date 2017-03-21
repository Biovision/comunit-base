class My::MessagesController < ApplicationController
  before_action :restrict_anonymous_access

  # get /my/messages
  def index
    @collection = UserMessage.page_for_owner(current_user, current_page)
  end

  # get /my/messages/:user_slug
  def dialog
    set_interlocutor
    @collection = UserMessage.dialog_page(current_user, @interlocutor, current_page)
  end

  private

  def set_interlocutor
    @interlocutor = User.with_long_slug(params[:user_slug])
    if !@interlocutor.is_a?(User) || @interlocutor.deleted?
      render :not_found, status: :not_found
    end
  end
end
