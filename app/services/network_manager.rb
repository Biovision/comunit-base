class NetworkManager
  MAIN_HOST = 'http://comunit.online'

  # @param [Site] site
  # @param [Hash] attributes
  # @param [Hash] data
  def update_site(site, attributes, data = {})
    site.assign_attributes(attributes)
    site.save!
  end

  # @param [User] entity
  # @param [Hash] attributes
  # @param [Hash] data
  def update_user(entity, attributes, data = {})
    entity.assign_attributes(attributes)
    unless data[:image_path].blank?
      entity.remote_image_url = "#{MAIN_HOST}#{data[:image_path]}"
    end
    entity.save!
  end

  # @param [Region] entity
  # @param [Hash] attributes
  # @param [Hash] data
  def update_region(entity, attributes, data = {})
    entity.assign_attributes(attributes)
    unless data[:image_path].blank?
      entity.remote_image_url = "#{MAIN_HOST}#{data[:image_path]}"
    end
    unless data[:header_image_path].blank?
      entity.remote_header_image_url = "#{MAIN_HOST}#{data[:header_image_path]}"
    end
    entity.save!
  end

  # @param [User] user
  def relink_user(user)
    url     = "#{MAIN_HOST}/network/users/relink"
    allowed = User.relink_parameters
    # Залепа для переходного периода
    attributes = user.attributes.select { |a| allowed.include?(a) }
    if user.respond_to?(:religion)
      attributes.merge!(religion_name: user.religion)
    end
    data    = {
        user: attributes,
        data: Hash.new
    }
    unless user.agent.nil?
      data[:data][:agent_name] = user.agent.name
    end
    unless user.image.blank?
      data[:data][:image_path] = user.image.url
    end
    response = RestClient.post(url, JSON.generate(data), request_headers)
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
end
