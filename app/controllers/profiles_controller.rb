class ProfilesController < ApplicationController
  before_action :set_entity

  # get /u/:slug
  def show
  end

  # get /u/:slug/entries
  def entries
    @collection = Post.of_type('blog_post').owned_by(@entity).page_for_visitors(current_page)
  end

  # get /u/:slug/followees
  def followees
    @filter     = params[:filter] || Hash.new
    @collection = UserLink.filtered(:followee, @filter).with_follower(@entity).page_for_user(current_page)
  end

  private

  def set_entity
    @entity = User.find_by(slug: params[:slug].downcase)
    if @entity.nil? || @entity.deleted?
      handle_http_404 "Cannot find user by slug: #{params[:slug]}"
    end
  end
end
