module HasOwner
  extend ActiveSupport::Concern

  included do
    scope :owned_by, ->(user) { where user: user }
  end

  # @param [User] user
  def owned_by?(user)
    user.is_a?(User) && (self.user == user)
  end

  def owner_name
    if user.is_a? User
      user.profile_name
    else
      I18n.t(:anonymous)
    end
  end
end
