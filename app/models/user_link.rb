class UserLink < ApplicationRecord
  include Toggleable

  PER_PAGE = 10

  toggleable :visible

  belongs_to :agent, optional: true
  belongs_to :followee, class_name: User.to_s, counter_cache: :follower_count
  belongs_to :follower, class_name: User.to_s, counter_cache: :followee_count

  validates_uniqueness_of :followee, scope: [:follower]

  scope :visible, -> { where(visible: true) }
  scope :recent, -> { order('id desc') }
  scope :with_follower, -> (user) { where(follower: user) }
  scope :with_followee, -> (user) { where(followee: user) }

  # @param [Integer] page
  def self.page_for_user(page)
    recent.page(page).per(PER_PAGE)
  end

  # @param [User] follower
  # @param [User] followee
  def self.follow(follower, followee)
    if follower.is_a?(User) && followee.is_a?(User)
      criteria = { follower_id: follower.id, followee_id: followee.id }
      link = find_or_create_by(criteria)
      link.reciprocal.update(visible: true) if link.mutual?
      link
    else
      raise "#{follower.class}, #{followee.class}"
    end
  end

  # @param [User] follower
  # @param [User] followee
  def self.unfollow(follower, followee)
    with_follower(follower).with_followee(followee).destroy_all
  end

  # @param [Symbol] side
  # @param [Hash] filter
  def self.filtered(side, filter)
    link = joins(side).where("users.id = user_links.#{side}_id")
    unless filter[:screen_name].blank?
      link = link.where('users.screen_name ilike ?', "%#{filter[:screen_name]}%")
    end
    unless filter[:name].blank?
      link = link.where('users.name ilike ?', "%#{filter[:name]}%")
    end
    unless filter[:surname].blank?
      link = link.where('users.surname ilike ?', "%#{filter[:surname]}%")
    end
    unless filter[:online].blank?
      link = link.where('users.last_seen >= ?', 3.minutes.ago)
    end
    link
  end

  def mutual?
    reciprocal.exists?
  end

  def reciprocal
    UserLink.where(follower: followee, followee: follower)
  end
end
