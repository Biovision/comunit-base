class UserRole < ApplicationRecord
  include HasOwner

  belongs_to :user

  enum role: [:administrator, :moderator, :chief_editor, :post_editor, :news_editor]

  validates_presence_of :role
  validates_uniqueness_of :role, scope: [:user_id]

  # @param [User] user
  # @param [Symbol] suitable_roles
  def self.user_has_role?(user, *suitable_roles)
    available_roles, result = [], false
    suitable_roles.each { |role| available_roles << self.roles[role] if self.role_exists? role }
    result = self.exists? user: user, role: available_roles if available_roles.any?
    result || (user.is_a?(User) && user.super_user?)
  end

  # @param [Symbol] role
  def self.role_exists?(role)
    self.roles.has_key? role
  end

  # @param [User] user
  def self.has_any_role?(user)
    self.exists?(user: user) || (user.is_a?(User) && user.super_user?)
  end
end
