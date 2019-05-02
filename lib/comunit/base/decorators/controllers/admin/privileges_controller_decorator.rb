Admin::PrivilegesController.class_eval do
  # get /admin/privileges/:id/regions
  def regions
    @user       = User.find_by(id: params[:user_id])
    @collection = Region.visible.for_tree(nil, params[:parent_id]).reject { |r| @entity.has_user?(@user, r.subbranch_ids) }
  end
end
