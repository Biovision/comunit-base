module Comunit
  module Base
    module BaseMethods
      extend ActiveSupport::Concern

      included do
        helper_method :current_user_has_role?, :current_user_has_privilege?
        helper_method :current_region
      end

      # @return [Region]
      def current_region
        @current_region
      end

      # @param [Symbol] role
      def current_user_has_role?(*role)
        UserRole.user_has_role? current_user, *role
      end

      # @param [Symbol] privilege_name
      # @param [Region] region
      def current_user_has_privilege?(privilege_name, region = nil)
        UserPrivilege.user_has_privilege?(current_user, privilege_name, region)
      end

      protected

      # @param [Symbol] role
      def require_role(*role)
        if current_user.is_a? User
          redirect_to root_path, alert: t(:insufficient_role) unless current_user.has_role? *role
        else
          redirect_to login_path, alert: t(:please_log_in)
        end
      end

      # @param [Symbol] privilege_name
      def require_privilege(privilege_name)
        unless current_user_has_privilege?(privilege_name, current_region)
          handle_http_401("Current user has no privilege #{privilege_name}")
        end
      end

      # @param [Symbol] name
      def require_privilege_group(name)
        unless UserPrivilege.user_in_group?(current_user, name)
          handle_http_401("Current user has no privilege class #{name}")
        end
      end

      def set_current_region
        region_slug     = request.subdomains.first
        @current_region = Region.find_by(slug: region_slug)
      end
    end
  end
end