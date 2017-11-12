class Appeal < ApplicationRecord
  include Toggleable
  include HasOwner

  PER_PAGE      = 20
  SUBJECT_LIMIT = 140
  NAME_LIMIT    = 100
  EMAIL_LIMIT   = 200
  PHONE_LIMIT   = 30
  BODY_LIMIT    = 5000

  toggleable :processed

  belongs_to :appeal_type, optional: true, counter_cache: true
  belongs_to :user, optional: true
  belongs_to :agent, optional: true
  belongs_to :responder, class_name: User.to_s, foreign_key: :responder_id

  after_initialize { self.uuid = SecureRandom.uuid if uuid.nil? }
  validates_presence_of :subject, :body
  validates_length_of :subject, maximum: SUBJECT_LIMIT
  validates_length_of :name, maximum: NAME_LIMIT
  validates_length_of :email, maximum: EMAIL_LIMIT
  validates_length_of :body, maximum: BODY_LIMIT
  validates_length_of :phone, maximum:  PHONE_LIMIT
  validates_length_of :response, maximum: BODY_LIMIT

  scope :recent, -> { order('id desc') }

  # @param [Integer] page
  def self.page_for_administration(page = 1)
    recent.page(page).per(PER_PAGE)
  end

  def self.creation_parameters
    %i(name phone email subject body)
  end

  def self.entity_parameters
    %i(response)
  end

  # @param [User] user
  def apply_user(user)
    return if user.nil?
    self.name  = user.profile_name
    self.email = user.email
    self.phone = user.phone
  end
end
