# frozen_string_literal: true

Admin::PostsController.class_eval do
  # get /admin/posts/regions
  def regions
    @collection = RegionManager.new(current_user).for_tree(params[:parent_id])
  end
end
