class ProfilesController < ApplicationController
  layout 'blog'

  before_action :set_entity

  # get /u/:slug
  def show
  end

  # get /u/:slug/entries
  def entries
    @collection = @entity.entries.page_for_visitors(current_user, current_page)
  end

  # get /u/:slug/followees
  def followees
    @filter     = params[:filter] || Hash.new
    @collection = UserLink.filtered(:followee, @filter).with_follower(@entity).page_for_user(current_page)
  end

  private

  def set_entity
    @entity = User.with_long_slug(params[:slug])
    if @entity.nil? || @entity.deleted?
      handle_http_404 "Cannot find user by slug: #{params[:slug]}"
    end
  end
end
