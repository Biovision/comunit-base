class Admin::CommentsController < AdminController
  before_action :restrict_access

  # get /admin/comments
  def index
    @collection = Comment.page_for_administration current_page
  end

  protected

  def restrict_access
    require_privilege :moderator
  end
end
