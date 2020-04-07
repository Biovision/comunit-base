# frozen_string_literal: true

module Comunit
  module Network
    # Logging network-related events
    module Logging
      # @param [String] text
      def log(text)
        file = "#{Rails.root}/log/network_manager.log"
        File.open(file, 'ab') do |f|
          f.puts "#{Time.now.strftime('%F %T')}\t#{text}"
        end

        nil
      end

      # @param [String] text
      def log_info(text)
        log("[I] #{text}")
      end

      # @param [String] text
      def log_error(text)
        log("[E] #{text}")
      end

      # @param [String] text
      def log_warn(text)
        log("[W] #{text}")
      end
    end
  end
end
