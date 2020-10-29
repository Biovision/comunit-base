# frozen_string_literal: true

# Adds method for linking users
module LinkedUsers
  extend ActiveSupport::Concern

  included do
    before_action :set_entity, only: %i[add_user remove_user users]
  end

  # get /admin/[table_name]/:id/users
  def users
    @collection = @entity.users.page_for_administration(current_page)
  end

  # put /admin/[table_name]/:id/users/:user_id
  def add_user
    @entity.add_user(User.find_by(id: params[:user_id]))

    head :no_content
  end

  # delete /admin/[table_name]/:id/users/:user_id
  def remove_user
    @entity.remove_user(User.find_by(id: params[:user_id]))

    head :no_content
  end
end
