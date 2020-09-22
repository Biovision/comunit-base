# frozen_string_literal: true

# Network site
#
# Attributes:
#   active [Boolean]
#   created_at [DateTime]
#   data [JSONb]
#   description [String], optional
#   host [String]
#   image [SimpleImageUploader], optional
#   local [Boolean]
#   name [String]
#   token [String]
#   updated_at [DateTime]
#   users_count [Integer]
#   uuid [UUID]
#   version [Integer]
class Site < ApplicationRecord
  include Checkable
  include HasUuid
  include RequiredUniqueName
  include Toggleable

  DESCRIPTION_LIMIT = 255
  HOST_LIMIT = 100
  NAME_LIMIT = 50

  toggleable :active # , :local

  has_secure_token

  mount_uploader :image, SimpleImageUploader

  has_many :site_users, dependent: :delete_all
  has_many :site_posts, dependent: :delete_all

  validates_presence_of :host
  validates_length_of :description, maximum: DESCRIPTION_LIMIT
  validates_length_of :host, maximum: HOST_LIMIT
  validates_length_of :name, maximum: NAME_LIMIT

  scope :active, -> { where(active: true) }
  scope :min_version, ->(v = 1) { where('version >= ?', v) }
  scope :list_for_visitors, -> { active.order('host asc') }
  scope :list_for_administration, -> { order('active desc, host asc') }

  # @param [Integer] page
  def self.page_for_administration(page = 1)
    list_for_administration.page(page)
  end

  def self.entity_parameters
    %i[active description host image local name token version]
  end

  # @param [User] user
  def self.ids_for_user(user)
    UserSite.owned_by(user).pluck(:site_id)
  end

  # @param [String] uuid
  def self.[](uuid)
    find_by(uuid: uuid)
  end

  def signature
    "#{id}:#{token}"
  end

  # @param [Post] post
  def post_state(post)
    site_posts.find_by(post: post)
  end

  # @param [User] user
  def user?(user)
    site_users.where(user: user).exists?
  end

  # @param [User] user
  def add_user(user)
    site_users.create(user: user)
  end

  # @param [User] user
  def remove_user(user)
    site_users.where(user: user).delete_all
  end

  # @param [Post] post
  # @param [User] user
  def allow_broadcast?(post, user)
    return false if version < 1 || !active || post.site_id == id || !user?(user)

    post_state(post).nil?
  end
end
