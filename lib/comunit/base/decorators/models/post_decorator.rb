# frozen_string_literal: true

Post.class_eval do
  belongs_to :region, optional: true

  before_save :track_region_change

  scope :in_region, ->(region) { where(region_id: region&.id.nil? ? nil : region&.subbranch_ids) }
  # scope :regional, -> { where('region_id is not null') }
  scope :central, -> { where(region_id: nil) }

  # @param [Region] selected_region
  # @param [Region] excluded_region
  def self.regional(selected_region = nil, excluded_region = nil)
    excluded_ids = Array(excluded_region&.subbranch_ids)
    if selected_region.nil?
      chunk = excluded_ids.any? ? where('region_id not in (?)', excluded_ids) : where('region_id is not null')
    else
      chunk = where(region_id: selected_region.subbranch_ids - excluded_ids)
    end
    chunk
  end

  def prepare_slug
    postfix = (created_at || Time.now).strftime('%d%m%Y')

    if slug.blank?
      self.slug = "#{Canonizer.transliterate(title.to_s)}_#{postfix}"
    end

    slug_limit = 200 + postfix.length + 1
    self.slug = slug.downcase[0..slug_limit]
  end

  def track_region_change
    return unless region_id_changed?

    Region.update_post_count(*region_id_change)
  end
end
