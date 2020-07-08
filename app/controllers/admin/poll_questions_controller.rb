# frozen_string_literal: true

# Administrative part for hanlding poll questions
class Admin::PollQuestionsController < AdminController
  include ToggleableEntity
  include EntityPriority

  before_action :set_entity

  # get /admin/poll_questions/:id
  def show
  end

  private

  def component_class
    Biovision::Components::PollsComponent
  end

  def set_entity
    @entity = PollQuestion.find_by(id: params[:id])
    handle_http_404('Cannot find poll question') if @entity.nil?
  end
end
