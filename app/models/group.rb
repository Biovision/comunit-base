class Group < ApplicationRecord
  include RequiredUniqueName
  include RequiredUniqueSlug

  DESCRIPTION_LIMIT = 350

  has_many :user_groups, dependent: :destroy
  has_many :users, through: :user_groups

  validates_length_of :description, maximum: DESCRIPTION_LIMIT

  def self.page_for_administration
    ordered_by_name
  end

  def self.entity_parameters
    %i(name slug description)
  end

  # @param [User] user
  def has_user?(user)
    user_groups.where(user: user).exists?
  end

  # @param [User] user
  def add_user(user)
    UserGroup.find_or_create_by(user: user, group: self)
  end

  # @param [User] user
  def remove_user(user)
    user_groups.where(user: user).destroy_all
  end
end
