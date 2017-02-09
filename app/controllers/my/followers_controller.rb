class My::FollowersController < ApplicationController
  layout 'blog'

  before_action :restrict_anonymous_access

  # get /my/followers
  def index
    @filter = params[:filter] || Hash.new
    @collection = UserLink.filtered(:follower, @filter).with_followee(current_user).page_for_user(current_page)
  end
end
