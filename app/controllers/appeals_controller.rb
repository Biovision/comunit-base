class AppealsController < ApplicationController
  before_action :prepare_editable_page, only: [:new, :create]
  before_action :restrict_access, except: [:new, :create]
  before_action :set_entity, only: [:destroy]

  layout 'admin', except: [:new, :create]

  # get /appeals/new
  def new
    @entity = Appeal.new
    @entity.apply_user(current_user)
  end

  # post /appeals
  def create
    @entity = Appeal.new(creation_parameters)
    if @entity.save
      redirect_to(feedback_path, notice: t('appeals.create.success'))
    else
      render :new, status: :bad_request
    end
  end

  # delete /appeals/:id
  def destroy
    if @entity.update(deleted: true)
      flash[:notice] = t('appeals.destroy.success')
    end
    redirect_to admin_appeals_path
  end

  private

  def restrict_access
    require_privilege :appeal_manager
  end

  def set_entity
    @entity = Appeal.find_by(id: params[:id], deleted: false)
    if @entity.nil?
      handle_http_404("Cannot find appeal #{params[:id]}")
    end
  end

  def prepare_editable_page
    @editable_page = EditablePage.find_by(slug: 'feedback')
  end

  def entity_parameters
    params.require(:appeal).permit(Appeal.entity_parameters)
  end

  def creation_parameters
    entity_parameters.merge(owner_for_entity(true))
  end
end
