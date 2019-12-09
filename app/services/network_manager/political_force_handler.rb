# frozen_string_literal: true

# Synchronizing political forces with central site
class NetworkManager::PoliticalForceHandler < NetworkManager
  REMOTE_URL = "#{MAIN_HOST}/network/political_forces"

  def self.permitted_attributes
    %i[created_at name slug sync_state]
  end

  # Create political_force on central site
  #
  # @param [PoliticalForce] entity
  def create_remote(entity)
    log_event("[I] Creating remote political_force #{entity.id} (#{entity.uuid})")
    @entity = entity
    rest(:post, REMOTE_URL, data_for_remote)
  end

  # Update political_force on central site
  #
  # @param [PoliticalForce] entity
  def update_remote(entity)
    log_event("[I] Updating remote political_force #{entity.id} (#{entity.uuid})")
    @entity = entity
    rest(:patch, "#{REMOTE_URL}/#{entity.uuid}", data_for_remote)
  end

  # Create local post from remote data
  def create_local
    uuid = @data.dig(:id)

    log_event "[I] Creating local political_force #{uuid}"

    @entity = PoliticalForce.new(uuid: uuid)
    @entity.agent = Agent[@data.dig(:meta, :agent_name).to_s]

    apply_for_update

    @entity.save
    @entity
  end

  def update_local
    uuid = @data[:id]

    log_event "[I] Updating local political_force #{uuid}"

    @entity = PoliticalForce.find_by(uuid: uuid)

    if @entity.nil?
      log_event "[E] Cannot find political_force #{uuid}"
      false
    else
      apply_for_update
      @entity.save
    end
  end

  private

  def apply_for_update
    apply_attributes
    assign_image_from_data

    log_event "[I] Validation status: #{@entity.valid?}"
  end

  def data_for_remote
    {
      data: {
        id: @entity.uuid,
        type: @entity.class.table_name,
        attributes: attributes_for_remote,
        meta: meta_for_remote
      }
    }
  end

  def meta_for_remote
    result = {}
    result[:image_path] = @entity.image.path unless @entity.image.blank?

    result
  end
end
