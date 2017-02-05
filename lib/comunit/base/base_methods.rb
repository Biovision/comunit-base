module Comunit
  module Base
    module BaseMethods
      extend ActiveSupport::Concern

      included do
        helper_method :current_user, :current_user_has_role?
        helper_method :current_region
      end

      # @return [Region]
      def current_region
        @current_region
      end

      # Получить текущего пользователя из жетона доступа в куки
      #
      # @return [User|nil]
      def current_user
        @current_user ||= Token.user_by_token cookies['token'], true
      end

      # @param [Symbol] role
      def current_user_has_role?(*role)
        UserRole.user_has_role? current_user, *role
      end

      protected

      # Ограничить доступ для анонимных посетителей
      def restrict_anonymous_access
        redirect_to login_path, alert: t(:please_log_in) unless current_user.is_a? User
      end

      # @param [Symbol] role
      def require_role(*role)
        if current_user.is_a? User
          redirect_to root_path, alert: t(:insufficient_role) unless current_user.has_role? *role
        else
          redirect_to login_path, alert: t(:please_log_in)
        end
      end

      # Информация о текущем пользователе для сущности
      #
      # @param [Boolean] track
      def owner_for_entity(track = false)
        result = { user: current_user }
        result.merge!(tracking_for_entity) if track
        result
      end

      def set_current_region
        region_slug     = request.subdomains.first
        @current_region = Region.find_by(slug: region_slug)
      end
    end
  end
end