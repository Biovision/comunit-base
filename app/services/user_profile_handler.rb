# frozen_string_literal: true

# Handler for user profile
class UserProfileHandler
  NAME_LIMIT = 100

  GENDERS = { 0 => 'female', 1 => 'male' }.freeze

  def self.marital_statuses
    {
      0 => 'single',
      1 => 'dating',
      2 => 'engaged',
      3 => 'married',
      4 => 'in_love',
      5 => 'complicated',
      6 => 'in_active_search'
    }
  end

  def self.attitudes
    %w[alcohol_attitude smoking_attitude]
  end

  def self.flags
    %w[
      show_email show_phone show_secondary_phone show_birthday show_patronymic
      show_skype_uid show_home_address show_about
    ]
  end

  def self.allowed_parameters
    %w[
      gender name patronymic surname marital_status header_image home_city_name
      language_names country_name city_name home_address secondary_phone
      skype_uid nationality_name political_views religion_name about activities
      interests favorite_music favorite_movies favorite_shows favorite_books
      favorite_games favorite_quotes main_in_life main_in_people inspiration
    ] + attitudes + flags
  end

  def self.normalized_parameters(input)
    output = {
      gender: clean_gender(input['gender']),
      marital_status: normalized_marital_status(input['marital_status'])
    }
    flags.each { |f| output[f] = normalized_flag(input[f]) }
    attitudes.each { |a| output[a] = normalized_attitude(input[a].to_i) }
    output
  end

  # Restrict gender to only available values
  #
  # Defined gender is stored as integer.
  #
  # @param [Integer] input
  def self.clean_gender(input)
    gender_key = input.blank? ? nil : input.to_i
    GENDERS.key?(gender_key) ? gender_key : nil
  end

  def self.normalized_marital_status(input)
    key = input.blank? ? nil : input.to_i
    marital_statuses.key?(key) ? key : nil
  end

  def self.normalized_attitude(input)
    (-2..2).include?(input.to_i) ? input.to_i : 0
  end

  def self.normalized_flag(input)
    [true, false].include?(input) ? input : input.to_i.positive?
  end

  # Normalize profile parameters for storage
  #
  # Makes consistent format of profile hash.
  #
  # @param [Hash] input
  def self.clean_parameters(input)
    return {} unless input.respond_to?(:key?)

    output = normalized_parameters(input)
    (allowed_parameters - output.keys).each do |parameter|
      output[parameter] = input.key?(parameter) ? input[parameter].to_s : nil
    end
    output
  end

  # @param [User] user
  def self.search_string(user)
    [
      user.data.dig('profile', 'surname'),
      user.data.dig('profile', 'name'),
      user.uuid
    ].compact.join(' ')
  end
end
