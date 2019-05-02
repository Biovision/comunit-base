class User < ApplicationRecord
  include Toggleable

  EMAIL_PATTERN            = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z0-9][-a-z0-9]+)\z/i
  SLUG_PATTERN             = /\A[a-z0-9_]{1,30}\z/
  SCREEN_NAME_LIMIT        = 30
  SCREEN_NAME_PATTERN      = /\A[a-z0-9_]{1,30}\z/i
  SCREEN_NAME_PATTERN_HTML = '^[a-zA-Z0-9_]{1,30}$'
  SLUG_LIMIT               = 250
  EMAIL_LIMIT              = 250
  NOTICE_LIMIT             = 255
  PHONE_LIMIT              = 50

  PER_PAGE = 25

  METRIC_REGISTRATION            = 'users.registration.hit'
  METRIC_AUTHENTICATION_SUCCESS  = 'users.authentication.success.hit'
  METRIC_AUTHENTICATION_FAILURE  = 'users.authentication.failure.hit'
  METRIC_AUTHENTICATION_EXTERNAL = 'users.authentication.external.hit'

  toggleable %i(email_confirmed allow_mail allow_login)

  belongs_to :agent, optional: true
  belongs_to :site, optional: true, counter_cache: true
  belongs_to :region, optional: true, counter_cache: true, touch: false
  has_many :tokens, dependent: :destroy
  has_many :codes, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :follower_links, class_name: UserLink.to_s, foreign_key: :followee_id, dependent: :destroy
  has_many :followee_links, class_name: UserLink.to_s, foreign_key: :follower_id, dependent: :destroy
  has_many :sent_messages, class_name: UserMessage.to_s, foreign_key: :sender_id, dependent: :destroy
  has_many :received_messages, class_name: UserMessage.to_s, foreign_key: :receiver_id, dependent: :destroy
  has_many :user_privileges, dependent: :destroy
  has_many :privileges, through: :user_privileges
  has_many :user_groups, dependent: :destroy
  has_many :groups, through: :user_groups
  has_many :albums, dependent: :destroy
  has_many :appeals, dependent: :destroy

  has_secure_password

  before_validation { self.screen_name = screen_name.strip unless screen_name.nil? }
  before_validation { self.slug = screen_name.downcase unless screen_name.blank? }
  before_save :prepare_search_string

  validates_presence_of :screen_name, :email
  validates_format_of :screen_name, with: SCREEN_NAME_PATTERN, if: :native_slug?
  validates_format_of :email, with: EMAIL_PATTERN
  validates :screen_name, uniqueness: { case_sensitive: false }
  # validates :email, uniqueness: { case_sensitive: false }
  validates_length_of :slug, maximum: SLUG_LIMIT
  validates_length_of :screen_name, maximum: SLUG_LIMIT
  validates_length_of :email, maximum: EMAIL_LIMIT
  validates_length_of :phone, maximum: PHONE_LIMIT
  validates_length_of :notice, maximum: NOTICE_LIMIT

  mount_uploader :image, AvatarUploader

  scope :visible, -> { where(deleted: false) }
  scope :ordered_by_screen_name, -> { order('screen_name asc') }
  scope :bots, -> (flag) { where bot: flag.to_i > 0 unless flag.blank? }
  scope :screen_name_like, -> (val) { where 'screen_name ilike ?', "%#{val}%" unless val.blank? }
  scope :email_like, -> (val) { where 'email ilike ?', "%#{val}%" unless val.blank? }
  scope :with_email, -> (email) { where 'email ilike ?', email }
  scope :with_privilege, -> (privilege) { joins(:user_privileges).where(user_privileges: { privilege_id: privilege.ids }) }
  scope :with_privilege_ids, ->(privilege_ids) { joins(:user_privileges).where(user_privileges: { privilege_id: privilege_ids }) }
  scope :filtered, -> (f) { email_like(f[:email]).screen_name_like(f[:screen_name]) }
  scope :search, ->(q) { where('search_string like ?', "%#{q.downcase}%") unless q.blank? }

  # @param [Integer] page
  # @param [String] search_query
  def self.page_for_administration(page, search_query = '')
    search(search_query).order('id desc').page(page).per(PER_PAGE)
  end

  # @param [Integer] page
  # @param [String] search_query
  def self.page_for_visitors(page, search_query = '')
    visible.search(search_query).order('id desc').page(page).per(PER_PAGE)
  end

  def self.profile_parameters
    %i(image allow_mail birthday consent)
  end

  def self.sensitive_parameters
    %i(email password password_confirmation)
  end

  # Параметры при регистрации
  def self.new_profile_parameters
    profile_parameters + sensitive_parameters + %i(screen_name)
  end

  # Параметры для администрирования
  def self.entity_parameters
    new_profile_parameters + %i(slug bot allow_login email_confirmed phone_confirmed notice)
  end

  # Параметры для создания в админке
  def self.creation_parameters
    entity_parameters
  end

  def self.synchronization_parameters
    ignored = %w(id)
    column_names.reject { |c| ignored.include?(c) }
  end

  def self.relink_parameters
    ignored = %w(id external_id site_id agent_id image native_id legacy_slug legacy_password)
    result  = []
    column_names.each do |column|
      next if ignored.include?(column) || column =~ /_count$/

      result << column
    end
    result
  end

  # @param [String] long_slug
  def self.with_long_slug(long_slug)
    find_by slug: long_slug
  end

  def self.ids_range
    min = User.minimum(:id).to_i
    max = User.maximum(:id).to_i
    (min..max)
  end

  def long_slug
    slug
  end

  def profile
    data['profile']
  end

  # @return [String]
  def profile_name
    full_name
  end

  def name_for_letter
    data.dig('profile', 'name').blank? ? screen_name : data.dig('profile', 'name')
  end

  # @param [Boolean] include_patronymic
  def full_name(include_patronymic = false)
    result = [data.dig('profile', 'surname').to_s.strip, name_for_letter]
    result << data.dig('pforile', 'patronymic').to_s.strip if include_patronymic
    result.compact.join(' ')
  end

  def can_receive_letters?
    allow_mail? && !email.blank?
  end

  # @param [User] user
  def follows?(user)
    UserLink.where(follower: self, followee: user).exists?
  end

  def native_slug?
    !foreign_slug?
  end

  def age
    now    = Time.now
    bd     = birthday || now
    result = now.year - bd.year
    result = result - 1 if (bd.month > now.month || (bd.month >= now.month && bd.day > now.day))
    result
  end

  protected

  def email_should_be_reasonable
    if email.blank?
      self.email = nil
    else
      errors.add(:email, I18n.t('activerecord.errors.models.user.attributes.email.unreasonable')) unless email =~ EMAIL_PATTERN
    end
  end

  def slug_should_be_valid
    unless foreign_slug?
      unless slug =~ SLUG_PATTERN
        errors.add(:screen_name, I18n.t('activerecord.errors.models.user.attributes.slug.invalid'))
      end
    end
  end

  def prepare_search_string
    string = "#{slug} #{email} #{UserProfileHandler.search_string(self)}"

    self.search_string = string.downcase
  end
end
