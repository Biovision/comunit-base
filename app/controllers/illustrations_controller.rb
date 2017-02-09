class IllustrationsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :restrict_access
  layout false

  def create
    @illustration = Illustration.new(creation_parameters)
    @illustration.save!
  end

  private

  def restrict_access
    require_role :chief_editor, :editor
  end

  def creation_parameters
    {
        image: params[:upload],
        name: params[:upload].original_filename,
    }.merge(owner_for_entity)
  end
end
