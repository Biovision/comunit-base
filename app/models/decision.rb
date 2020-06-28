# frozen_string_literal: true

# Decision to make
#
# Attributes:
#   active [boolean]
#   answers [jsonb]
#   body [text]
#   created_at [DateTime]
#   data [jsonb]
#   end_date [date]
#   name [string]
#   simple_image_id [SimpleImage]
#   updated_at [DateTime]
#   uuid [uuid]
#   visible [boolean]
class Decision < ApplicationRecord
  include Checkable
  include HasSimpleImage
  include HasUuid
  include Toggleable

  NAME_LIMIT = 250

  toggleable :active, :visible

  has_many :decision_users, dependent: :delete_all

  validates_presence_of :body, :name
  validates_length_of :name, maximum: NAME_LIMIT

  scope :visible, -> { where(visible: true) }
  scope :recent, -> { order('id desc') }
  scope :list_for_visitors, -> { visible.recent }
  scope :list_for_administration, -> { recent }

  def self.entity_parameters
    %i[active body end_date name simple_image_id visible]
  end

  # @param [Hash] list
  def add_answers(list)
    new_answers = {}
    list.each do |answer_uuid, answer_text|
      next if answer_text.blank?

      new_answers[answer_uuid] = answer_text
    end

    self.answers = new_answers
    save
  end

  # @param [String] answer_uuid
  def answer_count(answer_uuid)
    decision_users.where(answer: answer_uuid).count
  end

  # @param [User] user
  def voted?(user)
    decision_users.owned_by(user).exists?
  end

  # @param [User] user
  # @param [String] answer_uuid
  def add_vote(user, answer_uuid)
    return if voted?(user)

    decision_users.owned_by(user).create(answer: answer_uuid)
  end

  # @param [User] user
  def remove_vote(user)
    decision_users.owned_by(user).delete_all
  end

  # @param [String] answer_uuid
  def percent(answer_uuid)
    vote_count = decision_users.count
    answer_count(answer_uuid).to_f / vote_count * 100
  end
end
