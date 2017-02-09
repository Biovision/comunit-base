class Api::IllustrationsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :restrict_access

  # post /api/illustrations
  def create
    @illustration = Illustration.new creation_parameters
    if @illustration.save
      render :show
    else
      render json: { errors: @illustration.errors }, status: :bad_request
    end
  end

  # delete /api/illustrations
  def destroy
    illustration = Illustration.find_by(id: params[:id])
    if illustration.nil?
      handle_http_404('Cannot find illustration')
    else
      illustration.destroy
      render json: 'ok'
    end
  end

  protected

  def restrict_access
    require_role :chief_editor, :post_editor, :news_editor
  end

  def creation_parameters
    params.require(:illustration).permit(Illustration.entity_parameters).merge(owner_for_entity)
  end
end
