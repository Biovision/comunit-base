# frozen_string_literal: true

# Model belongs to site
module BelongsToSite
  extend ActiveSupport::Concern

  included do
    after_initialize :ensure_site_presence

    scope :for_current_site, -> { for_site(Site[ENV['SITE_ID']]) }
    scope :for_site, ->(v) { where("coalesce(data->'comunit'->>'site_id', '') in (?, '')", v.uuid) unless v.blank? }

    def ensure_site_presence
      return unless data.dig('comunit', 'site_id').nil?

      data['comunit'] ||= {}
      data['comunit']['site_id'] = ENV['SITE_ID']
    end

    def site
      site_uuid = data.dig('comunit', 'site_id')

      return if site_uuid.nil?

      Site[site_uuid]
    end
  end
end
