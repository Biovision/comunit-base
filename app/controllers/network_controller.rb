class NetworkController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :validate_signature
  before_action { @manager = NetworkManager.new }

  protected

  def validate_signature
    signature = request.headers['HTTP_SIGNATURE'].to_s
    if signature != Rails.application.secrets.signature_token
      render json: { errors: { signature: 'invalid'}}, status: :unauthorized
    end
  end
end
