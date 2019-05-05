class My::ProfilesController < ApplicationController
  include Authentication

  before_action :redirect_authorized_user, only: %i[new create]
  before_action :restrict_anonymous_access, except: %i[check new create]

  # layout 'profile', only: %i[show edit]

  # post /my/profile/check
  def check
    @entity = User.new(creation_parameters)
  end

  # get /my/profile/new
  def new
    @entity = User.new
  end

  # post /my/profile
  def create
    if params[:agree]
      redirect_to root_path, alert: t('my.profiles.create.are_you_bot')
    else
      create_user
    end
  end

  # get /my/profile
  def show
  end

  # get /my/profile/edit
  def edit
  end

  # patch /my/profile
  def update
    if current_user.update(user_parameters)
      NetworkUserSyncJob.perform_later(current_user.id, true)

      form_processed_ok(my_path)
    else
      form_processed_with_error(:edit)
    end
  end

  protected

  def redirect_authorized_user
    redirect_to my_profile_path if current_user.is_a? User
  end

  def create_user
    @entity = User.new(creation_parameters)
    if @entity.save
      Metric.register(User::METRIC_REGISTRATION)
      create_token_for_user(@entity)
      cookies.delete('r', domain: :all)
      NetworkUserSyncJob.perform_later(@entity.id, false)

      redirect_after_creation
    else
      form_processed_with_error(:new)
    end
  end

  def creation_parameters
    parameters = params.require(:user).permit(User.new_profile_parameters)
    parameters.merge!(tracking_for_entity)
    parameters[:super_user] = User.count < 1
    if cookies['r']
      parameters[:inviter] = User.find_by(referral_link: cookies['r'])
    end

    parameters
  end

  def user_parameters
    sensitive  = sensitive_parameters
    editable   = User.profile_parameters + sensitive
    parameters = params.require(:user).permit(editable)
    new_data   = current_user.data.merge(profile: profile_parameters)

    filter_parameters(parameters.merge(data: new_data), sensitive)
  end

  def profile_parameters
    permitted = UserProfileHandler.allowed_parameters
    dirty     = params.require(:user_profile).permit(permitted)
    UserProfileHandler.clean_parameters(dirty)
  end

  def sensitive_parameters
    if current_user.authenticate params[:password].to_s
      User.sensitive_parameters
    else
      []
    end
  end

  def filter_parameters(parameters, sensitive)
    sensitive.each { |parameter| parameters.except! parameter if parameter.blank? }
    parameters[:email_confirmed] = false if parameters[:email] && parameters[:email] != current_user.email
    parameters[:phone_confirmed] = false if parameters[:phone] && parameters[:phone] != current_user.phone
    parameters
  end

  def redirect_after_creation
    return_path = cookies['return_path'].to_s
    return_path = my_profile_path unless return_path[0] == '/'
    cookies.delete 'return_path', domain: :all

    flash[:notice] = t('my.profiles.create.success')

    form_processed_ok(return_path)
  end
end
