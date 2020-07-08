# frozen_string_literal: true

# Administrative part of hanlding poll answers
class Admin::PollAnswersController < AdminController
  include ToggleableEntity
  include EntityPriority

  before_action :set_entity

  # get /admin/poll_answers/:id
  def show
    @collection = @entity.poll_votes.page_for_administration(current_page)
  end

  private

  def component_class
    Biovision::Components::PollsComponent
  end

  def set_entity
    @entity = PollAnswer.find_by(id: params[:id])
    handle_http_404('Cannot find poll answer') if @entity.nil?
  end
end
