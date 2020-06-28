# frozen_string_literal: true

# Decision by user
#
# Attributes:
#   agent_id [Agent], optional
#   answer [uuid]
#   created_at [DateTime]
#   data [jsonb]
#   decision_id [Decision]
#   ip [inet]
#   region_id [Region], optional
#   updated_at [DateTime]
#   user_id [User]
class DecisionUser < ApplicationRecord
  include HasOwner

  belongs_to :agent, optional: true
  belongs_to :decision
  belongs_to :region, optional: true
  belongs_to :user

  validates_presence_of :answer
  validates_uniqueness_of :decision_id, scope: :user_id
end
