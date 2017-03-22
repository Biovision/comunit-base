module FeedbackHelper
  # @param [Appeal] entity
  def admin_appeal_link(entity)
    link_to(entity.subject, admin_appeal_path(entity.id))
  end
end
