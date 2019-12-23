# frozen_string_literal: true

# Synchronizing candidates with central site
class NetworkManager::CandidateHandler < NetworkManager
  REMOTE_URL = "#{MAIN_HOST}/network/candidates"

  def self.permitted_attributes
    %i[
      about approved birthday created_at lead name patronymic program region_id
      surname sync_state
    ]
  end

  # Create candidate on central site
  #
  # @param [Candidate] entity
  def create_remote(entity)
    log_event("[I] Creating remote candidate #{entity.id} (#{entity.uuid})")
    @entity = entity
    rest(:post, REMOTE_URL, data_for_remote)
  end

  # Update candidate on central site
  #
  # @param [Candidate] entity
  def update_remote(entity)
    log_event("[I] Updating remote candidate #{entity.id} (#{entity.uuid})")
    @entity = entity
    rest(:patch, "#{REMOTE_URL}/#{entity.uuid}", data_for_remote)
  end

  # Create local post from remote data
  def create_local
    uuid = @data.dig(:id)

    log_event "[I] Creating local candidate #{uuid}"

    @entity = Candidate.new(uuid: uuid)
    @entity.agent = Agent[@data.dig(:meta, :agent_name).to_s]

    apply_for_update

    assign_forces_from_data if @entity.save

    @entity
  end

  def update_local
    uuid = @data[:id]

    log_event "[I] Updating local candidate #{uuid}"

    @entity = Candidate.find_by(uuid: uuid)

    if @entity.nil?
      log_event "[E] Cannot find candidate #{uuid}"
      false
    else
      apply_for_update
      @entity.save
    end
  end

  private

  def apply_for_update
    apply_attributes
    assign_user_from_data
    assign_region_from_data
    assign_campaign_from_data
    assign_image_from_data

    log_event "[I] Validation status: #{@entity.valid?}"
  end

  def assign_campaign_from_data
    campaign_data = @data.dig(:relationships, :campaign, :data).to_h

    campaign = Campaign.find_by(uuid: campaign_data[:id])
    log_event("[W] Cannot find campaign #{campaign_data[:id]}") if campaign.nil?

    @entity.campaign = campaign
  end

  def assign_forces_from_data
    ids = []

    Array(@data.dig(:relationships, :political_forces, :data)).each do |link|
      political_force = PoliticalForce.find_by(uuid: link[:id])
      if political_force.nil?
        log_event "[W] cannot find political_force #{link[:id]}"
      else
        ids << political_force.id
      end
    end

    @entity.political_force_ids = ids
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
      region: RegionHandler.relationship_data(@entity.region, true),
      user: UserHandler.relationship_data(@entity.user, true),
      campaign: CampaignHandler.relationship_data(@entity.campaign),
      political_forces: { data: political_forces_data }
    }
  end

  def political_forces_data
    @entity.political_forces.map do |political_force|
      PoliticalForceHandler.relationship_data(political_force, false)
    end
  end

  def meta_for_remote
    result = {}
    result[:image_path] = @entity.image.path unless @entity.image.blank?
    result[:agent_name] = @entity.agent.name unless @entity.agent.blank?

    result
  end
end
