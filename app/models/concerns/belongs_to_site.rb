# frozen_string_literal: true

# Model belongs to site
module BelongsToSite
  extend ActiveSupport::Concern

  included do
    belongs_to :site

    after_initialize { self.site = Site[ENV['SITE_ID']] if site.nil? }

    scope :for_current_site, -> { for_site(Site[ENV['SITE_ID']]) }
    scope :for_site, ->(v) { where(site: v) unless v.blank? }
  end
end
