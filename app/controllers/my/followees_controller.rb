class My::FolloweesController < ApplicationController
  layout 'blog'

  before_action :restrict_anonymous_access

  # get /my/followees
  def index
    @filter = params[:filter] || Hash.new
    @collection = UserLink.filtered(:followee, @filter).with_follower(current_user).page_for_user(current_page)
  end
end
