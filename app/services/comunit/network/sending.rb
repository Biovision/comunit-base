# frozen_string_literal: true

module Comunit
  module Network
    # Sender for REST requests
    module Sending
      # Send REST request
      #
      # Depending on being central site, sends REST request to center or current
      # site.
      # If current site is inactive, no request is performed and status 503
      # is returned.
      #
      # @param [Symbol] verb
      # @param [String] path
      # @param [Hash] data
      # @return [Integer] HTTP response status
      def rest(verb, path, data)
        log_info("#{verb.to_s.upcase} #{path}")
        if Handler.central_site?
          if site&.active?
            rest_request(verb, "#{site.host}/#{path}", data)
          else
            log_warn('Site is inactive', 503)
          end
        else
          rest_request(verb, "#{Handler::MAIN_HOST}/#{path}", data)
        end
      end

      # Check environment and perform rest request
      #
      # @param [Symbol] verb
      # @param [String] url
      # @param [Hash] data
      def rest_request(verb, url, data)
        if Rails.env.production?
          rest_production(verb, url, JSON.generate(data))
        else
          log_info("[#{Rails.env}]: #{verb} #{url}", 200)
        end
      rescue RestClient::Exception => e
        log_error "Failed with #{e.http_code}: #{e}\n#{e.response}", e.http_code
      end

      # Perform REST request in production
      #
      # @param [Symbol] verb
      # @param [String] url
      # @param [String] payload
      def rest_production(verb, url, payload)
        response = RestClient.send(verb, url, payload, request_headers)
        log_info("Response #{response.code}:\n#{response.body.inspect}\n")
        response.code
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
