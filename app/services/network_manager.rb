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

  protected

  # @param [String] url
  # @param [Hash] data
  def rest_put(url, data)
    log_event("PUT #{url}")
    begin
      response = RestClient.put(url, JSON.generate(data), request_headers)
      log_event("Response (#{response.code}):\n#{response.body.inspect}\n")
      response
    rescue RestClient::Exception => e
      log_event("Failed with #{e.http_code}: #{e}\n#{e.response}")
    end
  end

  # @param [String] url
  # @param [Hash] data
  def rest_patch(url, data)
    log_event("PATCH #{url}")
    begin
      response = RestClient.patch(url, JSON.generate(data), request_headers)
      log_event("Response (#{response.code}):\n#{response.body.inspect}\n")
      response
    rescue RestClient::Exception => e
      log_event("Failed with #{e.http_code}: #{e}\n#{e.response}")
    end
  end

  # @param [String] url
  # @param [Hash] data
  def rest_post(url, data)
    log_event("POST #{url}")
    begin
      response = RestClient.post(url, JSON.generate(data), request_headers)
      log_event("Response (#{response.code}):\n#{response.body.inspect}\n")
      response
    rescue RestClient::Exception => e
      log_event("Failed with #{e.http_code}: #{e}\n#{e.response}")
    end
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
