class FeaturedPostsController < AdminController
  before_action :set_entity, only: :destroy

  # post /featured_posts
  def create
    @entity = FeaturedPost.new(creation_parameters)
    if @entity.save
      render status: :created
    else
      render json: { errors: @entity.errors }, status: :bad_request
    end
  end

  # delete /featured_posts/:id
  def destroy
    @entity.destroy

    head :no_content
  end

  private

  def component_class
    Biovision::Components::PostsComponent
  end

  def restrict_access
    handle_http_403('Forbidden') unless component_handler.group?(:chief)
  end

  def creation_parameters
    post = Post.find_by(id: params[:post_id])
    { post_id: post&.id }
  end

  def set_entity
    @entity = FeaturedPost.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find featured_post')
    end
  end
end
