module CommentsHelper
  # @param [Comment] entity
  def admin_comment_link(entity)
    link = link_to(entity.commentable.title, admin_comment_path(entity.id))

    raw "#{entity.commentable.model_name.human} <cite>#{link}</cite>"
  end

  # @param [Comment] entity
  def comment_link(entity)
    link = link_to(entity.commentable.title, entity.commentable)

    raw "#{entity.commentable.model_name.human} <cite>#{link}</cite>"
  end
end
