class IllustrationsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :restrict_access
  layout false

  # post /illustrations
  def create
    @illustration = Illustration.create!(creation_parameters)
  end

  private

  def restrict_access
    require_privilege_group :editors unless current_user&.verified?
  end

  def creation_parameters
    {
        image: params[:upload],
        name: params[:upload].original_filename,
    }.merge(owner_for_entity)
  end
end
