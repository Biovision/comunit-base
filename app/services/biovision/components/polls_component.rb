# frozen_string_literal: true

module Biovision
  module Components
    # Managing polls
    class PollsComponent < BaseComponent

      protected

      # @param [Hash] data
      # @return [Hash]
      def normalize_settings(data)
        result = {}
        numbers = %w[answer_limit question_limit]
        numbers.each { |f| result[f] = data[f].to_i }

        result
      end
    end
  end
end