class AppealsController < ApplicationController
  before_action :prepare_editable_page, only: [:new, :create]
  before_action :restrict_access, except: [:new, :create]
  before_action :set_entity, only: [:destroy, :update]

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
      next_page = feedback_path
      respond_to do |format|
        format.html { redirect_to(next_page, notice: t('appeals.create.success')) }
        format.json { render(json: { links: { next: next_page } }) }
        format.js { render js: "document.location.href = '#{next_page}'" }
      end
    else
      render :new, status: :bad_request
    end
  end

  # patch /appeals/:id
  def update
    if @entity.update(entity_parameters)
      next_page = admin_appeal_path(@entity.id)
      respond_to do |format|
        format.html { redirect_to(next_page) }
        format.json { render(json: { links: { next: next_page } }) }
        format.js { render js: "document.location.href = '#{next_page}'" }
      end
      AppealsMailer.appeal_reply(@entity.id).deliver_later
    else
      render :edit, status: :bad_request
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
    parameters = params.require(:appeal).permit(Appeal.entity_parameters)
    parameters.merge(responder_id: current_user.id, processed: true)
  end

  def creation_parameters
    parameters = params.require(:appeal).permit(Appeal.creation_parameters)
    parameters.merge(owner_for_entity(true))
  end
end
