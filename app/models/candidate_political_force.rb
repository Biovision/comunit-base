# frozen_string_literal: true

# Link between candidate and political force
#
# Attributes:
#   candidate_id [Candidate]
#   created_at [DateTime]
#   political_force_id [PoliticalForce]
#   updated_at [DateTime]
class CandidatePoliticalForce < ApplicationRecord
  belongs_to :candidate
  belongs_to :political_force, counter_cache: :candidates_count

  validates_uniqueness_of :political_force_id, scope: :candidate_id
end
