# frozen_string_literal: true

# Poll question
# 
# Attributes:
#   comment [string], optional
#   created_at [DateTime]
#   data [jsonb]
#   multiple_choice [boolean]
#   poll_answers_count [integer]
#   poll_id [Poll]
#   priority [integer]
#   simple_image_id [SimpleImage], optional
#   text [string]
#   updated_at [DateTime]
#   uuid [uuid]
class PollQuestion < ApplicationRecord
  include Checkable
  include HasSimpleImage
  include HasUuid
  include NestedPriority
  include Toggleable

  COMMENT_LIMIT = 255
  TEXT_LIMIT = 255

  toggleable :multiple_choice

  belongs_to :poll, counter_cache: true
  has_many :poll_answers, dependent: :delete_all

  before_validation { self.text = text.to_s.strip }

  validates_presence_of :text
  validates_length_of :text, maximum: TEXT_LIMIT
  validates_length_of :comment, maximum: COMMENT_LIMIT
  validates_uniqueness_of :text, scope: :poll_id

  scope :list_for_visitors, -> { ordered_by_priority }
  scope :list_for_administration, -> { ordered_by_priority }

  # @param [PollQuestion] entity
  def self.siblings(entity)
    where(poll_id: entity&.poll_id)
  end

  def self.entity_parameters
    PollQuestion.toggleable_attributes + %i[comment simple_image_id text]
  end

  def self.creation_parameters
    entity_parameters + %i[poll_id]
  end

  # @param [User] user
  def editable_by?(user)
    poll.editable_by?(user)
  end

  def vote_count
    poll_answers.pluck(:poll_votes_count).sum
  end
end
