module VotesHelper
  # @param [ApplicationRecord] entity
  def admin_votable_link(entity)
    text = entity.model_name.human
    path = '#'
    if entity.is_a?(Comment)
      text << ": #{entity.commentable.model_name.human}"
      text << " <cite>#{entity.commentable.title}</cite>"
      path = admin_comment_path(id: entity.id)
    end
    link_to(text.html_safe, path)
  end

  # @param [ApplicationRecord] entity
  def votable_link(entity)
    text = entity.model_name.human
    path = '#'
    if entity.is_a?(Comment)
      text += " #{entity.commentable.title}"
      path = entity.commentable
    end
    link_to(text, path)
  end
end
