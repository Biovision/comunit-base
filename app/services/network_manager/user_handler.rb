class NetworkManager::UserHandler < NetworkManager

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

  # @param [User] user
  def relink_user(user)
    log_event("Relinking user #{user.id}")
    url     = "#{MAIN_HOST}/network/users/relink"
    allowed = User.relink_parameters
    # Залепа для переходного периода
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
    unless user.agent.nil?
      data[:data][:agent_name] = user.agent.name
    end
    unless user.image.blank?
      data[:data][:image_path] = user.image.url
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
end
