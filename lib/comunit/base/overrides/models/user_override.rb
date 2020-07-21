# frozen_string_literal: true

User.class_eval do
  # has_many :follower_links, class_name: UserLink.to_s, foreign_key: :followee_id, dependent: :destroy
  # has_many :followee_links, class_name: UserLink.to_s, foreign_key: :follower_id, dependent: :destroy
  # has_many :sent_messages, class_name: UserMessage.to_s, foreign_key: :sender_id, dependent: :destroy
  # has_many :received_messages, class_name: UserMessage.to_s, foreign_key: :receiver_id, dependent: :destroy
  has_many :appeals, dependent: :destroy

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