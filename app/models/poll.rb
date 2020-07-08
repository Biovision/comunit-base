# frozen_string_literal: true

# Poll
# 
# Attributes:
#   active [boolean]
#   agent_id [Agent], optional
#   allow_comments [Boolean]
#   anonymous_votes [boolean]
#   comments_count [integer]
#   created_at [DateTime]
#   data [jsonb]
#   description [string], optional
#   end_date [date], optional
#   exclusive [boolean]
#   ip [inet]
#   language_id [Language], optional
#   name [string]
#   open_results [boolean]
#   poll_questions_count [integer]
#   pollable_id [integer], optional
#   pollable_type [string], optional
#   show_on_homepage [boolean]
#   simple_image_id [SimpleImage], optional
#   updated_at [DateTime]
#   user_id [User]
#   uuid [uuid]
#   visible [boolean]
class Poll < ApplicationRecord
  include Checkable
  include HasOwner
  include HasSimpleImage
  include HasUuid
  include Toggleable

  NAME_LIMIT        = 140
  DESCRIPTION_LIMIT = 255

  toggleable %i[active anonymous_votes open_results show_on_homepage exclusive visible]

  belongs_to :user
  belongs_to :agent, optional: true
  belongs_to :pollable, polymorphic: true, optional: true
  has_many :poll_questions, dependent: :delete_all
  has_many :poll_users, dependent: :delete_all

  validates_presence_of :name
  validates_length_of :description, maximum: DESCRIPTION_LIMIT
  validates_length_of :name, maximum: NAME_LIMIT

  scope :recent, -> { order('id desc') }
  scope :visible, -> { where(visible: true) }
  scope :active, -> { where('active = true and (end_date is null or (date(end_date) >= date(now())))') }
  scope :list_for_visitors, -> { active.visible.recent }
  scope :list_for_administration, -> { recent }

  # @param [Integer] page
  def self.page_for_administration(page = 1)
    list_for_administration.page(page)
  end

  # @param [Integer] page
  def self.page_for_visitors(page = 1)
    list_for_visitors.page(page)
  end

  def self.entity_parameters
    Poll.toggleable_attributes + %i[description end_date name simple_image_id]
  end

  # @param [User] user
  def editable_by?(user)
    return false if user.nil?

    owned_by?(user)
  end

  # @param [User] user
  def visible_to?(user)
    visible? || owned_by?(user)
  end

  # @param [User] user
  def votable_by?(user)
    return false if user.nil? || voted?(user)

    if exclusive?
      includes?(user)
    # elsif anonymous_votes?
    else
      true
    end
  end

  # @param [User] user
  def voted?(user)
    PollVote.where(poll_answer_id: answer_ids, user: user).exists?
  end

  # @param [User] user
  def show_results?(user)
    open_results? || editable_by?(user)
  end

  # @param [User] user
  def includes?(user)
    poll_users.owned_by(user).exists?
  end

  # @param [User] user
  def add_user(user)
    PollUser.create(poll: self, user: user)
  end

  # @param [User] user
  def remove_user(user)
    poll_users.owned_by(user).delete_all
  end

  def answer_ids
    PollAnswer.where(poll_question_id: poll_questions.pluck(:id)).pluck(:id)
  end

  # @param [User] user
  # @param [Hash] answers
  # @param [Hash] tracking
  # @param [String] slug
  def process_answers(user, answers, tracking, slug)
    return unless votable_by?(user)

    answers.each do |question_id, answer_ids|
      question = PollQuestion.find_by(id: question_id)
      next if question.nil? || question.poll_id != id

      if question.multiple_choice?
        answers = question.poll_answers.where(id: answer_ids)
      else
        answers = question.poll_answers.where(id: answer_ids.first)
      end

      answers.each do |answer|
        tracking[:slug] = slug
        answer.poll_votes.create(tracking)
      end
    end
  end
end
