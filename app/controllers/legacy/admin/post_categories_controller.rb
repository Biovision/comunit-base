class Legacy::Admin::PostCategoriesController < AdminController
  before_action :set_entity, except: [:index]

  def index
    @collection = PostCategory.for_tree
  end

  # get /admin/post_categories/:id
  def show
  end

  # get /admin/post_categories/:id/items
  def items
    @collection = Post.in_category(@entity).page_for_administration current_page
  end

  protected

  # def component_class
    # Biovision::Components::PostsComponent
  # end

  def set_entity
    @entity = PostCategory.find params[:id]
    raise record_not_found if @entity.deleted?
  end
end
