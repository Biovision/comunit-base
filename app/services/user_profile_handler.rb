class UserProfileHandler
  NAME_LIMIT = 100

  GENDERS = { 0 => 'female', 1 => 'male' }
  MARITAL = {
    0 => 'single',
    1 => 'dating',
    2 => 'engaged',
    3 => 'married',
    4 => 'in_love',
    5 => 'complicated',
    6 => 'in_active_search'
  }

  def self.allowed_parameters
    %w(
      gender name patronymic surname show_email show_phone show_secondary_phone
      show_birthday show_patronymic show_skype_uid show_home_address show_about
      marital_status smoking_attitude alcohol_attitude header_image
      home_city_name language_names country_name city_name home_address
      secondary_phone skype_uid nationality_name political_views religion_name
      about activities interests favorite_music favorite_movies favorite_shows
      favorite_books favorite_games favorite_quotes main_in_life main_in_people
      inspiration
    )
  end

  # @param [Hash] input
  def self.clean_parameters(input)
    if input.key?('gender')
      gender_key = input['gender'].to_i
      gender     = GENDERS.key?(gender_key) ? gender_key : nil
    else
      gender = nil
    end

    if input.key?('marital_status')
      ms_key  = input['marital_status'].to_i
      marital = MARITAL.key?(ms_key) ? ms_key : nil
    else
      marital = nil
    end

    enums = %w(gender marital_status)
    flags = %w(
      show_email show_phone show_secondary_phone show_birthday show_patronymic
      show_skype_uid show_home_address show_about
    )

    output = { gender: gender, marital_status: marital }
    (allowed_parameters - enums - flags).each do |parameter|
      output[parameter] = input.key?(parameter) ? input[parameter].to_s : nil
    end
    flags.each do |flag|
      output[flag] = [true, false].include?(flag) ? flag : (flag.to_i > 0)
    end
    output
  end

  # @param [User] user
  def self.search_string(user)
    "#{user.data.dig('profile', 'surname')} #{user.data.dig('profile', 'name')}"
  end
end

