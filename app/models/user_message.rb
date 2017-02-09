class UserMessage < ApplicationRecord
  include Toggleable

  PER_PAGE = 20

  toggleable :read_by_receiver, :deleted_by_sender, :deleted_by_receiver

  belongs_to :agent, optional: true
  belongs_to :sender, class_name: User.to_s
  belongs_to :receiver, class_name: User.to_s

  validates_presence_of :body

  scope :recent, -> { order('id desc') }
  scope :unread, -> { where(read_by_receiver: false) }
  scope :with_sender, -> (user) { where(sender_id: user) unless user.blank? }
  scope :with_receiver, -> (user) { where(receiver_id: user) unless user.blank? }
  scope :visible_to_sender, -> { where(deleted_by_sender: false) }
  scope :visible_to_receiver, -> { where(deleted_by_receiver: false) }
  scope :visible_to_user, -> (user) { where('(sender_id = ? and deleted_by_sender = false) or (receiver_id = ? and deleted_by_receiver = false)', user, user) }
  scope :owned_by, -> (user) { where('sender_id = ? and deleted_by_sender = false or receiver_id = ?', user, user) unless user.blank? }
  scope :filtered, -> (f) { owned_by(f[:user_id]).with_sender(f[:sender_id]).with_receiver(f[:receiver_id]) }

  # @param [Integer] page
  # @param [Hash] filter
  def self.page_for_administration(page, filter = {})
    filtered(filter).recent.page(page).per(PER_PAGE)
  end

  # @param [User] user
  # @param [Integer] page
  def self.page_for_owner(user, page)
    visible_to_user(user).recent.page(page).per(PER_PAGE)
  end

  # @param [User] user
  # @param [User] other_user
  # @param [Integer] page
  def self.dialog_page(user, other_user, page)
    clause      = 'sender_id = ? and receiver_id = ?'
    as_sender   = "(#{clause} and deleted_by_sender = false)"
    as_receiver = "(#{clause} and deleted_by_receiver = false)"
    where("#{as_sender} or #{as_receiver}", user, other_user, other_user, user).
        recent.page(page).per(PER_PAGE)
  end

  def self.entity_parameters
    %i(body)
  end

  def self.creation_parameters
    entity_parameters + %i(receiver_id)
  end

  # @param [User] user
  def destroy_by_user(user)
    if sender?(user)
      update(deleted_by_sender: true)
      receiver.long_slug
    elsif receiver?(user)
      update(deleted_by_receiver: true)
      sender.long_slug
    end
  end

  # @param [User] user
  def visible_to?(user)
    if sender?(user)
      !deleted_by_sender?
    elsif receiver?(user)
      !deleted_by_receiver?
    else
      false
    end
  end

  # @param [User] user
  def sender?(user)
    user == sender
  end

  # @param [User] user
  def receiver?(user)
    user == receiver
  end
end
