# frozen_string_literal: true

# Deed management for user
class My::DeedsController < ProfileController
  before_action :set_entity, except: :index
  before_action :set_category, only: %i[add_category remove_category]

  # get /my/deeds
  def index
    @collection = Deed.page_for_owner(current_user, current_page)
  end

  # get /my/deeds/:id
  def show
  end

  # put /my/deeds/:id/categories/:category_id
  def add_category
    @category.add_deed(@entity)

    head :no_content
  end

  # delete /my/deeds/:id/categories/:category_id
  def remove_category
    @category.remove_deed(@entity)

    head :no_content
  end

  private

  def set_entity
    @entity = Deed.owned_by(current_user).find_by(id: params[:id])
    handle_http_404("Cannot find deed for owner #{current_user&.id}") if @entity.nil?
  end

  def set_category
    @category = DeedCategory.list_for_visitors.find_by(id: params[:category_id])
    handle_http_404('Cannot find deed_category') if @category.nil?
  end
end
