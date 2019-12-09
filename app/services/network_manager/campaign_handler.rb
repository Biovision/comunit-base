# frozen_string_literal: true

# Synchronizing campaigns with central site
class NetworkManager::CampaignHandler < NetworkManager
  REMOTE_URL = "#{MAIN_HOST}/network/campaigns"

  def self.permitted_attributes
    %i[active created_at date name slug sync_state]
  end

  # Create campaign on central site
  #
  # @param [Campaign] entity
  def create_remote(entity)
    log_event("[I] Creating remote campaign #{entity.id} (#{entity.uuid})")
    @entity = entity
    rest(:post, REMOTE_URL, data_for_remote)
  end

  # Update campaign on central site
  #
  # @param [Campaign] entity
  def update_remote(entity)
    log_event("[I] Updating remote campaign #{entity.id} (#{entity.uuid})")
    @entity = entity
    rest(:patch, "#{REMOTE_URL}/#{entity.uuid}", data_for_remote)
  end

  # Create local post from remote data
  def create_local
    uuid = @data.dig(:id)

    log_event "[I] Creating local campaign #{uuid}"

    @entity = Campaign.new(uuid: uuid)

    apply_for_update

    @entity.save
    @entity
  end

  def update_local
    uuid = @data[:id]

    log_event "[I] Updating local campaign #{uuid}"

    @entity = Campaign.find_by(uuid: uuid)

    if @entity.nil?
      log_event "[E] Cannot find campaign #{uuid}"
      false
    else
      apply_for_update
      @entity.save
    end
  end

  private

  def apply_for_update
    apply_attributes
    assign_region_from_data
    assign_image_from_data

    log_event "[I] Validation status: #{@entity.valid?}"
  end

  def data_for_remote
    {
      data: {
        id: @entity.uuid,
        type: @entity.class.table_name,
        attributes: attributes_for_remote,
        relationships: relationships_for_remote,
        meta: meta_for_remote
      }
    }
  end

  # Relationship data in data.relationships block for remote create/update
  #
  # @return [Hash]
  def relationships_for_remote
    {
      region: RegionHandler.relationship_data(@entity.region),
    }
  end

  def meta_for_remote
    result = {}
    result[:image_path] = @entity.image.path unless @entity.image.blank?

    result
  end
end
