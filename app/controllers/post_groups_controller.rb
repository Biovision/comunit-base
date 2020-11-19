# frozen_string_literal: true

# Handling post groups
class PostGroupsController < ApplicationController
  # get /post_groups/:id
  def show
    @entity = PostGroup.visible.find_by(slug: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find post_group')
    else
      @collection = @entity.posts_page(current_page)
    end
  end

  private

  def component_class
    Biovision::Components::PostsComponent
  end
end
