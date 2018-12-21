module UsersHelper
  def attitudes_for_select
    options = [[t(:not_selected), '']]
    options + (-2..1).map { |o| [t("attitudes.#{o.to_s}"), o]}
  end

  # @param [Integer] gender_key
  def marital_statuses_for_select(gender_key)
    options = [[t(:not_selected), '']]
    options + UserProfileHandler::MARITAL.keys.map { |o| [marital_status_name(gender_key, o), o] }
  end

  # @param [Integer] gender_key
  # @param [Integer] key
  def marital_status_name(gender_key, key)
    gender = UserProfileHandler::GENDERS[gender_key]
    prefix = 'activerecord.attributes.user_profile.marital_statuses.'
    prefix << (gender.blank? ? 'default' : gender)
    if UserProfileHandler::MARITAL.key?(key)
      t("#{prefix}.#{UserProfileHandler::MARITAL[key]}")
    else
      t(:not_selected)
    end
  end

  # @param [User] user
  def marital_status_for_user(user)
    marital_status_name(user.data.dig('profile', 'gender'), user.data.dig('profile', 'marital_status'))
  end

  # @param [User] user
  def editorial_user_link(user)
    return t(:anonymous) if user.nil?
    text = user.profile_name
    link_to text, editorial_user_path(id: user.id), class: 'profile'
  end
end
