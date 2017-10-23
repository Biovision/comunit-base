class NetworkManager::UserHandler < NetworkManager

  # Обновить данные о пользователе извне
  #
  # Вызывается центральным сайтом при создании или обновлении пользователя
  #
  # @param [User] entity
  # @param [Hash] attributes
  # @param [Hash] data
  def update_user(entity, attributes, data = {})
    log_event("Updating user #{entity.id}:\n\t#{attributes}\n\t#{data}\n")
    allowed_for_user = User.synchronization_parameters
    user_attributes  = attributes.select { |a| allowed_for_user.include?(a.to_s) }
    entity.assign_attributes(user_attributes)
    unless data[:image_path].blank?
      entity.remote_image_url = "#{MAIN_HOST}#{data[:image_path]}"
    end

    entity.save!

    allowed_for_profile = UserProfile.entity_parameters
    profile_attributes  = attributes.select { |a| allowed_for_profile.include?(a.to_s) }
    entity.user_profile&.update!(profile_attributes)
  end

  # Синхронизировать нового пользователя
  #
  # Отправляет пользователя в центральный сайт и привязывает его внешний id
  # и site_id
  #
  # @param [User] user
  def relink_user(user)
    log_event("Relinking user #{user.id}")
    url     = "#{MAIN_HOST}/network/users/relink"
    data    = prepare_user_data(user)
    unless user.agent.nil?
      data[:data][:agent_name] = user.agent.name
    end
    log_event("Data: #{data.inspect}\n")

    response = RestClient.post(url, JSON.generate(data), request_headers)
    log_event("Response (#{response.code}):\n#{response.body.inspect}\n")

    if user.external_id.blank?
      parsed   = JSON.parse(response).dig('data')
      new_data = {
        external_id: parsed['user_id'],
        site_id:     parsed['site_id']
      }
      user.update!(new_data)
    end
  end

  # @param [User] user
  def sync_user(user)
    log_event("Syncing user #{user.id}")
    url  = "#{MAIN_HOST}/network/users/#{user.external_id}"
    data = prepare_user_data(user)
    log_event("Data: #{data.inspect}\n")

    response = RestClient.put(url, JSON.generate(data), request_headers)
    log_event("Response (#{response.code}):\n#{response.body.inspect}\n")
  end

  private

  # @param [User] user
  def prepare_user_data(user)
    allowed = User.relink_parameters

    attributes = user.attributes.select { |a| allowed.include?(a) }
    unless user.user_profile.nil?
      allowed_in_profile = UserProfile.entity_parameters
      profile_parameters = user.user_profile.attributes.select { |a| allowed_in_profile.include?(a) }
      attributes.merge!(profile_parameters)
    end
    data = {
      user: attributes,
      data: Hash.new
    }
    unless user.image.blank?
      data[:data][:image_path] = user.image.url
    end

    data
  end
end
