class EventParticipant < ApplicationRecord
  belongs_to :event
  belongs_to :user
  belongs_to :agent
end
