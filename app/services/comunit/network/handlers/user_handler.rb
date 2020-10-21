# frozen_string_literal: true

module Comunit
  module Network
    module Handlers
      # Handling users
      class UserHandler < Comunit::Network::Handler
        def self.permitted_attributes
          super + %i[
            birthday bot consent email email_confirmed foreign_slug
            ip language_id password_digest phone phone_confirmed screen_name
            slug super_user updated_at search_string referral_link
          ]
        end

        protected

        def pull_data
          apply_attributes
          apply_profile
          apply_agent
          apply_image
        end

        def apply_profile
          profile = data.dig('meta', 'profile')
          entity.data['profile'] = ::UserProfileHandler.clean_parameters profile
        end

        def meta_for_remote
          meta = super
          meta[:agent] = entity.agent&.name
          unless entity.image.blank?
            meta[:image_path] = entity.image.path
            meta[:image_url] = host + entity.image.url
          end

          meta
        end
      end
    end
  end
end
