# frozen_string_literal: true

# Common parts for working with Comunit network
class NetworkController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :validate_signature

  protected

  def validate_signature
    signature = request.headers['HTTP_SIGNATURE'].to_s
    if signature != Rails.application.credentials.signature_token
      render json: { errors: { signature: 'invalid'}}, status: :unauthorized
    end
  end
end
