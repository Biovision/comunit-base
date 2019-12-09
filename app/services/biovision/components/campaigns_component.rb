# frozen_string_literal: true

module Biovision
  module Components
    # Component for election campaigns
    class CampaignsComponent < BaseComponent
      SLUG = 'campaigns'

      def user_parameters?
        false
      end
    end
  end
end
