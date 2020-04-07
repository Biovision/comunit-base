# frozen_string_literal: true

module Comunit
  module Network
    module Handlers
      class UserHandler < Comunit::Network::Handler
        def self.permitted_attributes
          %i[
            birthday bot consent created_at email email_confirmed foreign_slug
            ip language_id password_digest phone phone_confirmed screen_name
            slug super_user updated_at uuid search_string referral_link
          ]
        end

        def self.ignored_attributes
          super + %w[image]
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
          entity.data['profile'] = ::UserProfileHandler.clean_parameters(profile)
        end

        def meta_for_remote
          meta = {
            profile: entity.data['profile'],
            agent: entity.agent&.name
          }
          meta[:image_path] = entity.image.path unless entity.image.blank?

          meta
        end
      end
    end
  end
end
