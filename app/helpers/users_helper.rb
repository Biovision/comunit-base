module UsersHelper
  def attitudes_for_select
    options = [[t(:not_selected), '']]
    options + (-2..1).map { |o| [t("attitudes.#{o.to_s}"), o]}
  end

  # @param [String] gender
  def marital_statuses_for_select(gender)
    prefix = 'activerecord.attributes.user_profile.marital_statuses.'
    prefix << (gender.blank? ? 'default' : gender)
    options = [[t(:not_selected), '']]
    options + UserProfile.marital_statuses.keys.map { |o| [t("#{prefix}.#{o}"), o] }
  end

  # @param [User] user
  def marital_status_for_user(user)
    profile = user.profile
    prefix = 'activerecord.attributes.user_profile.marital_statuses.'
    prefix << (profile.gender.blank? ? 'default' : profile.gender)
    t("#{prefix}.#{profile.marital_status}", default: :not_selected)
  end

  # @param [User] user
  def editorial_user_link(user)
    return t(:anonymous) if user.nil?
    text = user.profile_name
    link_to text, editorial_user_path(user.id), class: 'profile'
  end
end
