class User < ApplicationRecord
  include Toggleable

  EMAIL_PATTERN     = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z0-9][-a-z0-9]+)\z/i
  SLUG_PATTERN      = /\A[a-z0-9_]{1,30}\z/
  OLD_SLUG_PATTERN  = /\A[-a-z0-9_а-яё@&*. ]{3,30}\z/
  PER_PAGE          = 25

  METRIC_REGISTRATION  = 'users.registration.count'
  METRIC_AUTHORIZATION = 'users.authorization.count'

  toggleable %i(email_confirmed allow_mail allow_login verified)

  belongs_to :agent, optional: true
  belongs_to :site, optional: true, counter_cache: true
  belongs_to :region, optional: true, counter_cache: true, touch: false
  has_many :user_roles, dependent: :destroy
  has_many :tokens, dependent: :destroy
  has_many :codes, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :news, dependent: :destroy
  has_many :illustrations, dependent: :nullify
  has_many :entries, dependent: :destroy
  has_many :follower_links, class_name: UserLink.to_s, foreign_key: :followee_id, dependent: :destroy
  has_many :followee_links, class_name: UserLink.to_s, foreign_key: :follower_id, dependent: :destroy
  has_many :sent_messages, class_name: UserMessage.to_s, foreign_key: :sender_id, dependent: :destroy
  has_many :received_messages, class_name: UserMessage.to_s, foreign_key: :receiver_id, dependent: :destroy
  has_many :user_privileges, dependent: :destroy
  has_many :privileges, through: :user_privileges

  has_secure_password

  enum gender: [:female, :male]
  enum marital_status: [:single, :dating, :engaged, :married, :in_love, :complicated, :in_active_search]

  before_validation { self.screen_name = screen_name.strip unless screen_name.nil? }
  before_validation { self.slug = screen_name.downcase unless screen_name.blank? }

  validates_presence_of :slug
  validates_uniqueness_of :slug
  validate :slug_should_be_valid
  validate :email_should_be_reasonable

  mount_uploader :image, AvatarUploader

  scope :visible, -> { where(deleted: false) }
  scope :bots, -> (flag) { where bot: flag.to_i > 0 unless flag.blank? }
  scope :screen_name_like, -> (val) { where 'screen_name ilike ?', "%#{val}%" unless val.blank? }
  scope :name_like, -> (val) { where 'name ilike ?', "%#{val}%" unless val.blank? }
  scope :surname_like, -> (val) { where('surname ilike ?', "%#{val}%") unless val.blank? }
  scope :email_like, -> (val) { where 'email ilike ?', "%#{val}%" unless val.blank? }
  scope :with_email, -> (email) { where 'email ikike ?', email }
  scope :with_roles, -> (roles) { joins(:user_roles).where(user_roles: { role: roles }) unless roles.blank? }
  scope :with_privilege, -> (privilege) { joins(:privilege_users).where(privilege_users: { privilege_id: privilege.ids} ) }
  scope :filtered, -> (f) {
    name_like(f[:name]).surname_like(f[:surname]).email_like(f[:email]).
        screen_name_like(f[:screen_name]).with_roles(f[:roles])
  }

  # @param [Integer] page
  # @param [Hash] filter
  def self.page_for_administration(page, filter = {})
    bots(filter[:bots]).filtered(filter).order('slug asc').page(page).per(PER_PAGE)
  end

  # @param [Integer] page
  # @param [Hash] filter
  def self.page_for_visitors(page, filter = {})
    visible.filtered(filter).order('surname asc, name asc, slug asc').page(page).per(PER_PAGE)
  end

  def self.profile_parameters
    basic_data         = %i(image name patronymic surname birthday gender allow_mail marital_status home_city_name language_names)
    contact_data       = %i(region_id country_name city_name home_address phone secondary_phone skype_uid)
    about_data         = %i(about activities nationality_name interests favorite_music favorite_movies favorite_shows favorite_books favorite_games favorite_quotes)
    stand_in_life_data = %i(political_views religion_name main_in_life main_in_people smoking_attitude alcohol_attitude inspiration)
    flag_data          = %i(show_email show_phone show_secondary_phone show_birthday show_patronymic show_skype_uid show_home_address show_about allow_posts verified)
    basic_data + contact_data + about_data + stand_in_life_data + flag_data
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
    ignored = %w(id external_id site_id agent_id image native_id)
    result  = []
    column_names.each do |column|
      next if ignored.include?(column)
      next if column =~ /_count$/
      result << column
    end
    result
  end

  # @param [String] long_slug
  def self.with_long_slug(long_slug)
    find_by slug: long_slug
  end

  def long_slug
    slug
  end

  # @param [Boolean] include_patronymic
  def full_name(include_patronymic = false)
    parts = [surname, name]
    parts << patronymic if include_patronymic
    parts.join(' ').strip
  end

  def profile_name
    result = full_name(false)
    if result.blank?
      result = screen_name || slug
    end
    result
  end

  def name_for_letter
    name || profile_name
  end

  # @param [Array] suitable_roles
  def has_role?(*suitable_roles)
    UserRole.user_has_role? self, *suitable_roles
  end

  # @param [Symbol] role
  def add_role(role)
    if UserRole.role_exists? role
      UserRole.create user: self, role: role unless has_role? role
    end
  end

  # @param [Symbol] role
  def remove_role(role)
    UserRole.where(user: self, role: UserRole.roles[role]).destroy_all if UserRole.role_exists? role
  end

  # @param [Hash] roles
  def roles=(roles)
    roles.each do |role, flag|
      flag.to_i > 0 ? add_role(role) : remove_role(role)
    end
  end

  def can_receive_letters?
    allow_mail? && !email.blank?
  end

  # @param [User] user
  def follows?(user)
    UserLink.where(follower: self, followee: user).exists?
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
    pattern = legacy_slug? ? OLD_SLUG_PATTERN : SLUG_PATTERN
    errors.add(:screen_name, I18n.t('activerecord.errors.models.user.attributes.slug.invalid')) unless slug =~ pattern
  end
end
