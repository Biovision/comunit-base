module UsersHelper
  def attitudes_for_select
    options = [[t(:not_selected), '']]
    options + (-2..1).map { |o| [t("attitudes.#{o.to_s}"), o]}
  end

  def marital_statuses_for_select(gender)
    prefix = 'activerecord.attributes.user.marital_statuses.'
    prefix << (gender.blank? ? 'default' : gender)
    options = [[t(:not_selected), '']]
    options + User.marital_statuses.keys.map { |o| [t("#{prefix}.#{o}"), o] }
  end

  def marital_status_for_user(user)
    prefix = 'activerecord.attributes.user.marital_statuses.'
    prefix << (user.gender.blank? ? 'default' : user.gender)
    t("#{prefix}.#{user.marital_status}", default: :not_selected)
  end

  # @param [User] user
  def editorial_user_link(user)
    if user.nil?
      t(:anonymous)
    else
      text = user.profile_name
      link_to text, editorial_user_path(user.id), class: 'profile'
    end
  end
end
