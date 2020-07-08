# frozen_string_literal: true

# Answer to poll question
# 
# Attributes:
#   created_at [DateTime]
#   data [jsonb]
#   poll_question_id [PollQuestion]
#   poll_votes_count [integer]
#   priority [integer]
#   simple_image_id [SimpleImage], optional
#   text [string]
#   updated_at [DateTime]
#   uuid [uuid]
class PollAnswer < ApplicationRecord
  include Checkable
  include HasSimpleImage
  include HasUuid
  include NestedPriority

  TEXT_LIMIT = 140

  belongs_to :poll_question, counter_cache: true
  has_many :poll_votes, dependent: :delete_all

  before_validation { self.text = text.to_s.strip }

  validates_presence_of :text
  validates_length_of :text, maximum: TEXT_LIMIT
  validates_uniqueness_of :text, scope: :poll_question_id

  scope :list_for_visitors, -> { ordered_by_priority }
  scope :list_for_administration, -> { ordered_by_priority }

  # @param [PollAnswer] entity
  def self.siblings(entity)
    where(poll_question_id: entity&.poll_question_id)
  end

  def self.entity_parameters
    %i[text simple_image_id]
  end

  def self.creation_parameters
    entity_parameters + %i[poll_question_id]
  end

  # @param [User] user
  def editable_by?(user)
    poll_question.poll.editable_by?(user)
  end

  def poll
    poll_question&.poll
  end

  def vote_percent
    poll_votes_count.to_f / poll_question.vote_count * 100
  end
end
