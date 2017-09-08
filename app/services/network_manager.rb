class NetworkManager
  MAIN_HOST = 'http://comunit.online'

  # @param [Site] entity
  # @param [Hash] attributes
  # @param [Hash] data
  def update_site(entity, attributes, data = {})
    log_event("Updating site #{entity.id}:\n\t#{attributes}\n")
    entity.assign_attributes(attributes)
    entity.save!
  end

  # @param [User] entity
  # @param [Hash] attributes
  # @param [Hash] data
  def update_user(entity, attributes, data = {})
    log_event("Updating user #{entity.id}:\n\t#{attributes}\n\t#{data}\n")
    allowed_for_user = User.attribute_names
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

  # @param [Region] entity
  # @param [Hash] attributes
  # @param [Hash] data
  def update_region(entity, attributes, data = {})
    log_event("Updating region #{entity.id}:\n\t#{attributes}\n\t#{data}\n")
    entity.assign_attributes(attributes)
    unless data[:image_path].blank?
      entity.remote_image_url = "#{MAIN_HOST}#{data[:image_path]}"
    end
    entity.save!
    entity.parent&.cache_children!
  end

  # @param [User] user
  def relink_user(user)
    log_event("Relinking user #{user.id}")
    url     = "#{MAIN_HOST}/network/users/relink"
    allowed = User.relink_parameters
    # Залепа для переходного периода
    attributes = user.attributes.select { |a| allowed.include?(a) }
    if user.respond_to?(:religion)
      attributes.merge!(religion_name: user.religion)
    end
    unless user.user_profile.nil?
      allowed_in_profile = UserProfile.entity_parameters
      profile_parameters = user.user_profile.select { |a| allowed_in_profile.include?(a) }
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

  private

  def request_headers
    {
      content_type: :json,
      signature:    Rails.application.secrets.signature_token
    }
  end

  # @param [String] text
  def log_event(text)
    file = "#{Rails.root}/log/network_manager.log"
    File.open(file, 'ab') do |f|
      f.puts "#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}\t#{text}"
    end
  end
end
