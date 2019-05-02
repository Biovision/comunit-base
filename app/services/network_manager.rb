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
  def rest_put(url, data)
    rest(:put, url, data)
  end

  # @param [String] url
  # @param [Hash] data
  def rest_patch(url, data)
    rest(:patch, url, data)
  end

  # @param [String] url
  # @param [Hash] data
  def rest_post(url, data)
    rest(:post, url, data)
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
