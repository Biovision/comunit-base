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

  # post /admin/posts
  def create
    @entity = Post.new(creation_parameters)
    ensure_site_presence
    if @entity.save
      apply_linked_data_and_sync
      form_processed_ok(path_after_save)
    else
      form_processed_with_error(:new)
    end
  end

  def update
    if @entity.update(entity_parameters)
      apply_linked_data_and_sync
      form_processed_ok(path_after_save)
    else
      form_processed_with_error(:edit)
    end
  end

  private

  def component_class
    Biovision::Components::PostsComponent
  end

  # @param [String] q
  def search_posts(q)
    Post.search(q).page_for_administration(current_page)
  end

  def creation_parameters
    parameters = params.require(:post).permit(Post.entity_parameters)
    parameters.merge(owner_for_entity(true)).merge(owner_for_post)
  end

  def entity_parameters
    params.require(:post).permit(Post.entity_parameters).merge(owner_for_post)
  end

  def apply_linked_data_and_sync
    apply_post_taxa
    add_attachments if params.key?(:post_attachment)
    Comunit::Network::Handler.sync(@entity)
  end

  def apply_post_taxa
    if params.key?(:taxon_ids)
      @entity.taxon_ids = Array(params[:taxon_ids])
    else
      @entity.post_taxa.destroy_all
    end
  end

  def add_attachments
    permitted = PostAttachment.entity_parameters
    parameters = params.require(:post_attachment).permit(permitted)

    @entity.post_attachments.create(parameters)
  end

  def owner_for_post
    key = :user_for_entity
    result = {}
    if component_handler.group?(:chief) && params.key?(key)
      result[:user_id] = param_from_request(key)
    end
    result
  end
end
