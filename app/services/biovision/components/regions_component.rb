# frozen_string_literal: true

module Biovision
  module Components
    # Handler for regions component
    class RegionsComponent < BaseComponent
      def self.default_country_id
        Country.first&.id
      end
    end
  end
end
