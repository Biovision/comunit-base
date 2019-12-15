# frozen_string_literal: true

# Candidate for election campaign
#
# Attributes:
#   about [text], optional
#   agent_id [Agent], optional
#   approved [boolean]
#   birthday [date]
#   campaign_id [Campaign]
#   created_at [DateTime]
#   data [JSON]
#   details_url [String]
#   image [SimpleImageUploader]
#   ip [Inet]
#   lead [text]
#   name [string]
#   patronymic [string], optional
#   program [text], optional
#   region_id [Region], optional
#   supports_impeachment [Boolean]
#   surname [string]
#   sync_state [JSON]
#   updated_at [DateTime]
#   user_id [User], optional
#   uuid [uuid]
#   visible [boolean]
class Candidate < ApplicationRecord
  include Checkable
  include Toggleable
  include HasOwner

  ABOUT_LIMIT = 65_535
  LEAD_LIMIT = 500
  NAME_LIMIT = 50
  URL_LIMIT = 255

  toggleable :visible, :approved, :supports_impeachment

  mount_uploader :image, SimpleImageUploader

  belongs_to :agent, optional: true
  belongs_to :campaign, counter_cache: true
  belongs_to :region, optional: true
  belongs_to :user, optional: true
  has_many :candidate_political_forces, dependent: :destroy
  has_many :political_forces, through: :candidate_political_forces

  after_initialize { self.uuid = SecureRandom.uuid if uuid.nil? }

  validates_presence_of :birthday, :lead, :name, :surname
  validates_uniqueness_of :uuid
  validates_length_of :about, maximum: ABOUT_LIMIT
  validates_length_of :details_url, maximum: URL_LIMIT
  validates_length_of :lead, maximum: LEAD_LIMIT
  validates_length_of :name, maximum: NAME_LIMIT
  validates_length_of :patronymic, maximum: NAME_LIMIT
  validates_length_of :surname, maximum: NAME_LIMIT

  scope :visible, -> { where(approved: true, visible: true) }
  scope :ordered_by_surname, -> { order('surname asc, name asc, patronymic asc') }
  scope :list_for_visitors, -> { visible.ordered_by_surname }
  scope :list_for_administration, -> { ordered_by_surname }

  def self.entity_parameters(as_user = false)
    usual = %i[about birthday image lead name patronymic program surname]
    extended = %i[approved supports_impeachment visible]

    as_user ? usual : usual + extended
  end

  def self.creation_parameters(as_user = false)
    entity_parameters(as_user) + %i[campaign_id]
  end

  # @param [TrueClass|FalseClass] use_patronymic
  def full_name(use_patronymic = false)
    parts = [surname, name]
    parts << patronymic if use_patronymic

    parts.join(' ')
  end

  def image_alt_text
    full_name(true)
  end

  def age
    return 0 if birthday.blank?

    now = Time.now
    result = now.year - birthday.year
    result -= 1 if birthday.month > now.month || (birthday.month >= now.month && birthday.day > now.day)
    result
  end

  def assign_data_from_user
    return if user.nil?

    profile = user.data['profile'] || {}
    new_data = {
      name: profile['name'],
      patronymic: profile['patronymic'],
      surname: profile['surname'],
      birthday: user.data['birthday']
    }

    assign_attributes(new_data)
  end

  # @param [User] user
  # @param [String] role
  def user?(user, role)
    candidate_users.where(user: user).with_role(role).exists?
  end

  # @param [User] user
  # @param [String] role
  def team_membership_available?(user, role)
    return false if user.nil?

    !user?(user, role)
  end

  # @param [User] user
  # @param [String] role
  def add_user(user, role = nil)
    return if user.nil?
    return unless CandidateUser::ROLES.include?(role)

    instance = candidate_users.find_or_initialize_by(user: user)
    instance.data['roles'] ||= {}
    instance.data['roles'][role] = true

    instance.save
  end
end
