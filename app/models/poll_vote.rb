# frozen_string_literal: true

# Vote for poll answer
# 
# Attributes:
#   agent_id [Agent], optional
#   created_at [DateTime]
#   data [jsonb]
#   ip [inet], optional
#   poll_answer_id [PollAnswer]
#   slug [string]
#   updated_at [DateTime]
#   user_id [User], optional
#   uuid [uuid]
class PollVote < ApplicationRecord
  include HasOwner
  include HasUuid

  belongs_to :poll_answer, counter_cache: true
  belongs_to :user
  belongs_to :agent, optional: true

  scope :recent, -> { order('id desc') }
  scope :list_for_visitors, -> { recent }
  scope :list_for_administration, -> { recent }

  # @param [Integer] page
  def self.page_for_administration(page = 1)
    list_for_administration.page(page)
  end

  # @param [Integer] page
  def self.page_for_visitors(page = 1)
    list_for_visitors.page(page)
  end
end
