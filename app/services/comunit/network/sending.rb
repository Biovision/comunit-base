# frozen_string_literal: true

module Comunit
  module Network
    # Sender for REST requests
    module Sending
      # @param [Symbol] verb
      # @param [String] path
      # @param [Hash] data
      # @return [RestClient::Response]
      def rest(verb, path, data)
        log_info("#{verb.to_s.upcase} #{path}")
        if Handler.central_site?
          if site&.active?
            rest_request(verb, "#{site.host}/#{path}", data)
          else
            log_warn('Site is inactive')
          end
        else
          rest_request(verb, "#{Handler::MAIN_HOST}/#{path}", data)
        end
      end

      # @param [Symbol] verb
      # @param [String] url
      # @param [Hash] data
      def rest_request(verb, url, data)
        return unless Rails.env.production?

        payload = JSON.generate(data)
        response = RestClient.send(verb, url, payload, request_headers)
        log_info("Response #{response.code}:\n#{response.body.inspect}\n")
        response
      rescue RestClient::Exception => e
        log_error("Failed with #{e.http_code}: #{e}\n#{e.response}")
      end

      def request_headers
        {
          content_type: :json,
          signature: request_signature
        }
      end

      def request_signature
        if Handler.central_site?
          site&.signature
        else
          Rails.application.credentials.signature_token
        end
      end
    end
  end
end
