module Comunit
  module Base
    module BaseMethods
      extend ActiveSupport::Concern

      included do
        helper_method :current_user_has_privilege?, :current_user_in_group?
        helper_method :current_region
      end

      # @return [Region]
      def current_region
        @current_region
      end

      # @param [Symbol] privilege_name
      # @param [Region] region
      def current_user_has_privilege?(privilege_name, region = nil)
        UserPrivilege.user_has_privilege?(current_user, privilege_name, region)
      end

      # @param [Symbol] group_name
      def current_user_in_group?(group_name)
        ::UserPrivilege.user_in_group?(current_user, group_name)
      end

      protected

      # @param [Symbol] privilege_name
      def require_privilege(privilege_name)
        unless current_user_has_privilege?(privilege_name, current_region)
          handle_http_401("Current user has no privilege #{privilege_name}")
        end
      end

      # @param [Symbol] group_name
      def require_privilege_group(group_name)
        return if current_user_in_group?(group_name)
        handle_http_401("Current user is not in group #{group_name}")
      end

      def set_current_region
        region_slug = param_from_request(:region_slug)
        if region_slug.blank?
          region_slug = request.subdomains.first
        end
        @current_region = Region.find_by(long_slug: region_slug)
      end
    end
  end
end