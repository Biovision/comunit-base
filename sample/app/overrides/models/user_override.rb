# frozen_string_literal: true

User.class_eval do
  def profile_name
    result = full_name
    result.blank? ? screen_name : full_name
  end

  # @param [TrueClass|FalseClass] include_patronymic
  def full_name(include_patronymic = false)
    result = [data.dig('profile', 'surname').to_s.strip, data.dig('profile', 'name')]
    result << data.dig('profile', 'patronymic').to_s.strip if include_patronymic
    result.compact.join(' ')
  end

  # @param [User] user
  def follows?(user)
    UserLink.where(follower: self, followee: user).exists?
  end

  def site
    Site.find_by(uuid: data.dig('comunit', 'site_id'))
  end
end
