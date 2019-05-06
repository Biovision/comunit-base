# frozen_string_literal: true

# Synchronizing regions with central site
class NetworkManager::RegionHandler < NetworkManager
  # @param [Region] entity
  def self.relationship_data(entity)
    return nil if entity.nil?

    {
      id: entity.id,
      type: entity.class.table_name,
      attributes: {
        slug: entity.slug
      }
    }
  end

  def create_local
    id = @data[:id]

    log_event "[I] Creating local region #{id}"

    @region = Region.new(id: id)

    apply_for_create

    # @region.parent&.cache_children! if
    @region.save
    @region
  end

  def update_local
    id = @data[:id]

    log_event "[I] Updating local region #{id}"

    @region = Region.find_by(id: id)

    if @region.nil?
      log_event "[E] Cannot find region #{id}"
      false
    else
      apply_for_update
      @region.save
    end
  end

  private

  def apply_for_create
    permitted = %i[
      children_cache created_at country_id data image_url latitude locative
      long_slug longitude name parent_id parents_cache short_name slug
      updated_at
    ]

    apply_attributes(permitted)

    log_event "[I] Validation status after create: #{@region.valid?}"
  end

  def apply_for_update
    permitted = %i[
      data image_url latitude locative long_slug longitude name short_name slug
    ]

    apply_attributes(permitted)

    log_event "[I] Validation status after update: #{@region.valid?}"
  end

  # @param [Array] permitted
  def apply_attributes(permitted)
    input = @data.dig(:attributes).to_h

    attributes = input.select { |a, _| permitted.include?(a.to_sym) }
    @region.assign_attributes(attributes)
  end
end
