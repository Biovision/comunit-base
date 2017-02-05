class Token < ApplicationRecord
  include HasOwner
  include Toggleable

  PER_PAGE = 20

  toggleable :active

  has_secure_token

  belongs_to :user
  belongs_to :agent, optional: true

  validates_uniqueness_of :token

  scope :recent, -> { order('last_used desc, id desc') }

  # @param [Integer] page
  def self.page_for_administration(page = 1)
    recent.page(page).per(PER_PAGE)
  end

  def self.entity_parameters
    %i(active)
  end

  def self.creation_parameters
    entity_parameters + %i(user_id)
  end

  # @param [String] input
  # @param [Boolean] touch_user
  def self.user_by_token(input, touch_user = false)
    unless input.blank?
      pair = input.split(':')
      self.user_by_pair pair[0], pair[1], touch_user if pair.length == 2
    end
  end

  # @param [Integer] user_id
  # @param [String] token
  # @param [Boolean] touch_user
  def self.user_by_pair(user_id, token, touch_user = false)
    instance = self.find_by user_id: user_id, token: token, active: true
    if instance.is_a?(self)
      instance.update_columns(last_used: Time.now)
      user = instance.user
      user.update_columns(last_seen: Time.now) if touch_user
      user
    else
      nil
    end
  end

  # @param [User] user
  def editable_by?(user)
    owned_by?(user) || UserRole.user_has_role?(user, :administrator)
  end

  def cookie_pair
    "#{user_id}:#{token}"
  end
end
