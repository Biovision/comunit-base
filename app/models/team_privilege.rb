# @deprecated Do not use
class TeamPrivilege < ApplicationRecord
  belongs_to :team, counter_cache: true
  belongs_to :privilege

  validates_uniqueness_of :privilege_id, scope: [:team_id]
end
