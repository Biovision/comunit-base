# frozen_string_literal: true

# Common parts for working with Comunit network
class NetworkController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :validate_signature
  before_action :set_handler

  # post /network/[table_name]
  def create
    @handler.data = params.require(:data).permit!
    @entity = @handler.create_local
    if @entity.persisted?
      render :show, status: :created
    else
      render 'shared/forms/check', status: :bad_request
    end
  end

  # patch /network/[table_name]/:id
  def update
    @handler.data = params.require(:data).permit!
    if @handler.update_local
      head :no_content
    else
      head :bad_request
    end
  end

  # put /comunit/:table_name/:uuid
  def pull
    if @handler.pull(params[:uuid])
      head :no_content
    else
      head :unprocessable_entity
    end
  end

  # put /comunit/:table_name/:id/amend
  def amend
    if @handler.amend(params[:id])
      head :no_content
    else
      head :unprocessable_entity
    end
  end

  protected

  def validate_signature
    signature = request.headers['HTTP_SIGNATURE'].to_s
    if signature != Rails.application.credentials.signature_token
      render json: { errors: { signature: 'invalid'} }, status: :unauthorized
    end
  end

  def set_handler
    data = params.require(:data).permit!
    model_name = params[:table_name].classify
    prefix = 'Comunit::Network::Handlers::'
    handler_class = "#{prefix}#{model_name}Handler".safe_constantize
    if handler_class
      @handler = handler_class[data]
    else
      render json: { errors: { handler: false } }, status: :unprocessable_entity
    end
  end
end
