# frozen_string_literal: true

# Petition sign
# 
# Attributes:
#   agent_id [Agent], optional
#   created_at [DateTime]
#   data [jsonb]
#   email [string]
#   ip [inet], optional
#   name [string]
#   petition_id [Petition]
#   region_id [Region], optional
#   surname [string]
#   updated_at [DateTime]
#   user_id [User], optional
#   uuid [uuid]
class PetitionSign < ApplicationRecord
  include Checkable
  include HasOwner
  include HasUuid

  NAME_LIMIT = 50
  EMAIL_LIMIT = 250

  belongs_to :petition, counter_cache: true
  belongs_to :user, optional: true
  belongs_to :agent, optional: true

  validates_presence_of :name, :surname, :email
  validates_length_of :name, maximum: NAME_LIMIT
  validates_length_of :surname, maximum: NAME_LIMIT
  validates_length_of :email, maximum: EMAIL_LIMIT

  scope :recent, -> { order('id desc') }
  scope :list_for_visitors, -> { recent }
  scope :list_for_administration, -> { recent }

  # @param [Integer] page
  def self.page_for_visitors(page = 1)
    list_for_visitors.page(page)
  end

  # @param [Integer] page
  def self.page_for_administration(page = 1)
    list_for_administration.page(page)
  end

  def self.entity_parameters
    %i[email name surname]
  end

  def self.creation_parameters
    entity_parameters + %i[petition_id]
  end
end
