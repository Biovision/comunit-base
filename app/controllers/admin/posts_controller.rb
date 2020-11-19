# frozen_string_literal: true

# Administrative part for posts management
class Admin::PostsController < AdminController
  include CreateAndModifyEntities
  include ListAndShowEntities
  include LockableEntity
  include ToggleableEntity

  before_action :set_entity, except: %i[check create index new search]

  # get /admin/posts
  def index
    @filter = params[:filter] || {}
    @collection = Post.page_for_administration(current_page, @filter)
  end

  # get /admin/posts/:id/images
  def images
    @collection = @entity.post_images.list_for_administration
  end

  # get /admin/posts/search?q=
  def search
    @collection = params.key?(:q) ? search_posts(param_from_request(:q)) : []
  end

  private

  def component_class
    Biovision::Components::PostsComponent
  end

  # @param [String] q
  def search_posts(q)
    if Post.respond_to?(:search)
      Post.search(q).records.page(current_page)
    else
      Post.pg_search(q).page_for_administration(current_page)
    end
  end
end
