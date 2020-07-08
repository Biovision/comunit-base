# frozen_string_literal: true

My::ProfilesController.class_eval do

  def update
    @entity = current_user
    if @entity.update(user_parameters)
      flash[:notice] = t('my.profiles.update.success')
      NetworkEntitySyncJob.perform_later(@entity.class.to_s, @entity.id)
      form_processed_ok(my_path)
    else
      form_processed_with_error(:edit)
    end
  end

  def redirect_after_creation
    NetworkEntitySyncJob.perform_later(@entity.class.to_s, @entity.id)

    return_path = cookies['return_path'].to_s
    return_path = my_profile_path unless return_path[0] == '/'
    cookies.delete 'return_path', domain: :all

    form_processed_ok(return_path)
  end
end
