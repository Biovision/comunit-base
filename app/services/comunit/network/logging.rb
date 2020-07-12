# frozen_string_literal: true

module Comunit
  module Network
    # Logging for network events
    module Logging
      # @param [String] text
      # @param return_value
      def log(text, return_value = nil)
        file = "#{Rails.root}/log/network_manager.log"
        File.open(file, 'ab') do |f|
          host = Handler.central_site? ? site&.host : 'comunit.online'
          f.puts "#{Time.now.strftime('%F %T')}\t#{host}\t#{text}"
        end

        return_value
      end

      # @param [String] text
      # @param return_value
      def log_info(text, return_value = nil)
        log("[I] #{text}", return_value)
      end

      # @param [String] text
      # @param return_value
      def log_error(text, return_value = nil)
        log("[E] #{text}", return_value)
      end

      # @param [String] text
      # @param return_value
      def log_warn(text, return_value = nil)
        log("[W] #{text}", return_value)
      end
    end
  end
end
