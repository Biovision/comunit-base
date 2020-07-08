# frozen_string_literal: true

# User allowed to vote in poll
# 
# Attributes:
#   created_at [DateTime]
#   poll_id [Poll]
#   user_id [User]
#   updated_at [DateTime]
class PollUser < ApplicationRecord
  include HasOwner

  belongs_to :poll
  belongs_to :user

  validates_uniqueness_of :user_id, scope: :poll_id

  scope :list_for_administration, -> { order('id desc') }
end
