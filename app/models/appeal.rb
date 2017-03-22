class Appeal < ApplicationRecord
  include Toggleable
  include HasOwner

  PER_PAGE = 20

  toggleable :processed

  belongs_to :user, optional: true
  belongs_to :agent, optional: true

  after_initialize { self.uuid = SecureRandom.uuid if uuid.nil? }
  validates_presence_of :subject, :body

  scope :recent, -> { order('id desc') }

  # @param [Integer] page
  def self.page_for_administration(page = 1)
    recent.page(page).per(PER_PAGE)
  end

  def self.entity_parameters
    %i(name phone email subject body)
  end

  # @param [User] user
  def apply_user(user)
    return if user.nil?
    self.name  = user.profile_name
    self.email = user.email
    self.phone = user.phone
  end
end
