class My::PostsController < ApplicationController
  before_action :restrict_anonymous_access

  # get /my/posts
  def index
    @collection = Post.page_for_owner(current_user, current_page)
  end
end
