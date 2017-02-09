class CommentsController < ApplicationController
  before_action :restrict_anonymous_access
  before_action :restrict_access, except: [:create]
  before_action :set_entity, only: [:show, :edit, :update, :destroy]

  # post /comments
  def create
    @entity = Comment.new creation_parameters
    if @entity.save
      notify_participants
      redirect_to(@entity.commentable || admin_comments_path, notice: t('comments.create.success'))
    else
      render :new
    end
  end

  # get /comments/:id
  def show
  end

  # get /comments/:id/edit
  def edit
  end

  # patch /comments/:id
  def update
    if @entity.update entity_parameters
      redirect_to @entity, notice: t('comments.update.success')
    else
      render :edit
    end
  end

  # delete /comments/:id
  def destroy
    if @entity.update deleted: true
      flash[:notice] = t('comments.destroy.success')
    end
    redirect_to(@entity.commentable || admin_comments_path)
  end

  private

  def restrict_access
    require_role :administrator
  end

  def set_entity
    @entity = Comment.find params[:id]
  end

  def entity_parameters
    permitted = current_user_has_role?(:administrator) ? Comment.administrative_parameters : Comment.entity_parameters
    params.require(:comment).permit(permitted)
  end

  def creation_parameters
    params.require(:comment).permit(Comment.creation_parameters).merge(owner_for_entity).merge(tracking_for_entity)
  end

  def notify_participants
    commentable = @entity.commentable
    unless commentable.owned_by?(current_user)
      category = Notification.category_from_object(commentable)
      Notification.notify(commentable.user, category, commentable.id)
      # begin
      #   Comments.entry_reply(@entity).deliver_now if @entity.notify_entry_owner?
      # rescue Net::SMTPAuthenticationError => error
      #   logger.warn error.message
      # end
    end
  end
end
