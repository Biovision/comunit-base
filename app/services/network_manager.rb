class NetworkManager
  MAIN_HOST = 'https://comunit.online'

  # @param [Site] entity
  # @param [Hash] attributes
  # @param [Hash] data
  def update_site(entity, attributes, data = {})
    log_event("Updating site #{entity.id}:\n\t#{attributes}\n")
    entity.assign_attributes(attributes)
    entity.save!
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

  private

  def request_headers
    {
      content_type: :json,
      signature:    Rails.application.credentials.signature_token
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
