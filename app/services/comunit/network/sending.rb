# frozen_string_literal: true

module Comunit
  module Network
    # Sending signed REST requests
    module Sending
      # @param [String|Symbol] verb
      # @param [String] url
      # @param [Hash] data
      def rest(verb, url, data)
        log_info("#{verb.to_s.upcase} #{url}")
        response = RestClient.send(verb, url, JSON.generate(data), headers)
        log_info("Response (#{response.code}):\n#{response.body.inspect}\n")
        response
      rescue RestClient::Exception => e
        log_error("Failed with #{e.http_code}: #{e}\n#{e.response}")
        nil
      end

      def headers
        {
          content_type: :json,
          signature: Rails.application.credentials.signature_token
        }
      end
    end
  end
end
