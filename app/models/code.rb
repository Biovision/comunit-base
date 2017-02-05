class Code < ApplicationRecord
  include HasOwner

  PER_PAGE = 20

  belongs_to :user, optional: true
  belongs_to :agent, optional: true

  enum category: [:confirmation, :recovery, :invitation]

  validates_presence_of :body
  validates_uniqueness_of :body

  after_initialize :generate_body

  scope :recent, -> { order 'id desc' }
  scope :active, -> { where 'quantity > 0' }
  scope :confirmations, -> { where category: Code.categories[:confirmation] }
  scope :recoveries, -> { where category: Code.categories[:recovery] }
  scope :invitations, -> { where category: Code.categories[:invitation] }

  # @param [Integer] page
  def self.page_for_administration(page = 1)
    recent.page(page).per(PER_PAGE)
  end

  # @param [String] body
  def self.active_invitation(body)
    self.invitations.active.where(body: body).first
  end

  # @param [User] user
  def self.recovery_for_user(user)
    parameters = { user: user, category: categories[:recovery] }
    self.active.find_by(parameters) || self.create(parameters.merge(payload: user.email))
  end

  # @param [User] user
  def self.confirmation_for_user(user)
    parameters = { user: user, category: categories[:confirmation] }
    self.active.find_by(parameters) || self.create(parameters.merge(payload: user.email))
  end

  def self.entity_parameters
    %i(body payload quantity)
  end

  def self.creation_parameters
    entity_parameters + %i(user_id category)
  end

  def activated?
    self.quantity < 1
  end

  protected

  def generate_body
    if self.body.nil?
      self.body = ''
      Time.now.to_i.to_s(36).reverse.each_char do |char|
        self.body += char + rand(36).to_s(36)
      end
      4.times { self.body += rand(36).to_s(36) }

      self.body = self.body.scan(/.{4}/)[0..3].join('-')
    end
  end
end
