class Notification < ApplicationRecord
  include HasOwner

  PER_PAGE = 10

  belongs_to :user

  enum category: [:new_message, :new_follower, :entry_comment, :post_comment, :news_comment]

  validates_presence_of :category

  scope :unread, -> { where(read_by_user: false) }
  scope :recent, -> { order('id desc') }

  # @param [User] user
  # @param [Integer] page
  def self.page_for_owner(user, page)
    owned_by(user).recent.page(page).per(PER_PAGE)
  end

  # @param [User] user
  # @param [Integer] category
  # @param [Integer] payload
  def self.notify(user, category, payload)
    criteria = { user: user, category: category, payload: payload }
    instance = unread.find_by(criteria)
    if instance.nil?
      create!(criteria)
    else
      instance.increment! :repetition_count
    end
  end

  # @param [ApplicationRecord] entity
  def self.category_from_object(entity)
    case entity.class.to_s
      when UserMessage.to_s
        categories[:new_message]
      when UserLink.to_s
        categories[:new_follower]
      when Entry.to_s
        categories[:entry_comment]
      when Post.to_s
        categories[:post_comment]
      when News.to_s
        categories[:news_comment]
      else
        nil
    end
  end

  def payload_object
    case category.to_sym
      when :entry_comment
        Entry.find_by(id: payload)
      when :post_comment
        Post.find_by(id: payload)
      when :news_comment
        News.find_by(id: payload)
      else
        User.find_by(id: payload)
    end
  end
end
