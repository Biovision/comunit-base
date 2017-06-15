class EventParticipant < ApplicationRecord
  include Toggleable

  PER_PAGE = 20

  NAME_LIMIT    = 100
  EMAIL_LIMIT   = 250
  PHONE_LIMIT   = 50
  COMMENT_LIMIT = 10000
  NOTICE_LIMIT  = 250
  COMPANY_LIMIT = 250

  METRIC_CREATED = 'events.participants.created.hit'

  toggleable :processed

  belongs_to :event, counter_cache: true
  belongs_to :user, optional: true
  belongs_to :agent, optional: true

  validates_presence_of :name, :surname
  validates_length_of :name, maximum: NAME_LIMIT
  validates_length_of :surname, maximum: NAME_LIMIT
  validates_length_of :email, maximum: EMAIL_LIMIT
  validates_length_of :phone, maximum: PHONE_LIMIT
  validates_length_of :comment, maximum: COMMENT_LIMIT
  validates_length_of :notice, maximum: NOTICE_LIMIT
  validates_length_of :company, maximum: COMPANY_LIMIT

  scope :recent, -> { order('created_at desc') }
  scope :surname_like, ->(val) { where('surname ilike ?', "%#{val}%") unless val.blank? }
  scope :email_like, ->(val) { where('email ilike ?', "#{val}") unless val.blank? }
  scope :filtered, ->(f) { surname_like(f[:name]).email_like(f[:email]) }

  # @param [Integer] page
  # @param [Hash] filter
  def self.page_for_administration(page = 1, filter = {})
    filtered(filter).recent.page(page).per(PER_PAGE)
  end

  def self.entity_parameters
    %i(name surname email phone comment notice company)
  end

  def self.creation_parameters
    entity_parameters - %i(notice) + %i(event_id)
  end

  def full_name
    "#{surname} #{name}".strip
  end
end
