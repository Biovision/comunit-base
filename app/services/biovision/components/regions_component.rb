# frozen_string_literal: true

module Biovision
  module Components
    # Handler for regions component
    class RegionsComponent < BaseComponent
      SLUG = 'regions'

      def self.privilege_names
        %w[manager]
      end

      def self.default_country_id
        Country.first&.id
      end

      def allow_regions?
        return true if allow?('manager')

        RegionUser.where(user: user).exists?
      end

      def allowed_region_ids
        return nil if allow?('manager')
        return nil if RegionUser.where(user: user, region_id: nil).exists?

        parent_region_ids = RegionUser.where(user: user).pluck(:region_id)
        parent_region_ids + RegionUser.allowed_region_ids(user)
      end
    end
  end
end
