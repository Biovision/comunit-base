module Comunit
  module Base
    module PrivilegeMethods
      extend ActiveSupport::Concern

      included do
        helper_method :current_region
      end

      def current_region
        @current_region ||= set_current_region
      end

      protected

      def set_current_region
        region_slug = param_from_request(:region_slug)
        if region_slug.blank?
          region_slug = request.subdomains.first
        end
        if region_slug.blank?
          @current_region = CentralRegion.new
        else
          @current_region = Region.find_by(long_slug: region_slug) || CentralRegion.new
        end
      end
    end
  end
end
