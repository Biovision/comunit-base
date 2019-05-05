# frozen_string_literal: true

# Network manager for interaction with central site
class NetworkManager
  MAIN_HOST = 'https://comunit.online'

  attr_accessor :entity, :data

  # @param [Site] entity
  # @param [Hash] attributes
  # @param [Hash] data
  def update_site(entity, attributes, data = {})
    log_event("Updating site #{entity.id}:\n\t#{attributes}\n")
    entity.assign_attributes(attributes)
    entity.save!
  end

  protected

  def assign_user_from_data
    data = @data.dig(:relationships, :user).to_h

    slug = data.dig(:attributes, :slug)
    user = User.find_by(uuid: data[:id]) || User.find_by(slug: slug)

    @entity.user = user
  end

  def assign_region_from_data
    data = @data.dig(:relationships, :region).to_h

    slug = data.dig(:attributes, :long_slug)
    region = Region.find_by(id: data[:id]) || Region.find_by(long_slug: slug)

    @entity.region = region if @entity.respond_to?(:region=)
    @entity.data['comunit'] ||= {}
    @entity.data['comunit']['region_id'] = region&.id
  end

  def assign_image_from_data
    image_path = @data.dig(:meta, :image_path)

    return if image_path.blank? || !File.exist?(image_path)

    @entity.image = Pathname.new(image_path).open
  end

  # @param [String|Symbol] verb
  # @param [String] url
  # @param [Hash] data
  def rest(verb, url, data)
    log_event("[I] #{verb.to_s.upcase} #{url}")
    response = RestClient.send(verb, url, JSON.generate(data), request_headers)
    log_event("[I] Response (#{response.code}):\n#{response.body.inspect}\n")
    response
  rescue RestClient::Exception => e
    log_event("[E] Failed with #{e.http_code}: #{e}\n#{e.response}")
  end

  # @param [String] url
  # @param [Hash] data
  # @deprecated use #rest(:put, url, data)
  def rest_put(url, data)
    rest(:put, url, data)
  end

  def request_headers
    {
      content_type: :json,
      signature: Rails.application.credentials.signature_token
    }
  end

  # @param [String] text
  def log_event(text)
    file = "#{Rails.root}/log/network_manager.log"
    File.open(file, 'ab') do |f|
      f.puts "#{Time.now.strftime('%F %T')}\t#{text}"
    end
  end
end
