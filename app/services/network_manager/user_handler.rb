# frozen_string_literal: true

# Synchronizing users with central site
class NetworkManager::UserHandler < NetworkManager
  PATH = "#{MAIN_HOST}/network/users"

  # @param [User] entity
  # @param [TrueClass|FalseClass]
  def self.relationship_data(entity, wrap = false)
    return nil if entity.nil?

    data = {
      id: entity.uuid,
      type: entity.class.table_name,
      attributes: {
        slug: entity.slug
      }
    }

    wrap ? { data: data } : data
  end

  # @param [Hash] data
  def self.entity_from_relationship_data(data)
    return nil if data.blank?

    a = { uuid: data[:id] }
    b = { slug: data.dig(:attributes, :slug) }

    User.find_by(a) || User.find_by(b)
  end

  # Create user from remote data
  def create_local
    uuid = @data[:id]

    log_event "[I] Creating local user #{uuid}"

    @entity = User.new(uuid: uuid)
    @entity.agent = Agent.named(@data.dig(:meta, :agent_name).to_s)

    apply_for_create

    @entity.save
    @entity
  end

  # Update user from remote data
  def update_local
    uuid = @data[:id]

    log_event "[I] Updating local user #{uuid}"

    @entity = self.class.entity_from_relationship_data(@data)

    if @entity.nil?
      log_event "[E] Cannot find user #{uuid}"
      false
    else
      apply_for_update
      @entity.save
    end
  end

  # Push user to central site
  #
  # @param [User] entity
  def create_remote(entity)
    log_event("[I] Creating remote user #{entity.id} (#{entity.uuid})")
    @entity = entity
    rest(:post, PATH, data_for_remote)
  end

  # @param [User] entity
  def update_remote(entity)
    log_event("[I] Updating remote user #{entity.id} (#{entity.uuid})")
    @entity = entity
    rest(:put, "#{PATH}/#{entity.uuid}", data_for_remote)
  end

  private

  def apply_for_create
    assign_region_from_data
    assign_attributes
    assign_image_from_data

    r = @data.dig(:relationships)
    c = self.class
    @entity.inviter_id = c.entity_from_relationship_data(r[:inviter])&.id
    @entity.native_id = c.entity_from_relationship_data(r[:native])&.id
    @entity.consent = true

    log_event "[I] Validation status after create: #{@entity.valid?}"
  end

  def apply_for_update
    assign_region_from_data
    assign_attributes
    assign_image_from_data

    log_event "[I] Validation status after update: #{@entity.valid?}"
  end

  def assign_attributes
    permitted = %i[
      birthday bot consent data created_at email email_confirmed foreign_slug ip
      language_id password_digest phone phone_confirmed screen_name slug
      super_user updated_at uuid search_string referral_link
    ]

    input = @data.dig(:attributes).to_h

    attributes = input.select { |a, _| permitted.include?(a.to_sym) }
    @entity.assign_attributes(attributes)
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

  # Attributes for remote post create/update
  #
  # @return [Hash]
  def attributes_for_remote
    ignored = %w[id agent_id image inviter_id language_id native_id]

    @entity.attributes.reject { |a, _| ignored.include?(a) }
  end

  # Relationship data in data.relationships block for remote create/update
  #
  # @return [Hash]
  def relationships_for_remote
    {
      inviter: UserHandler.relationship_data(@entity.inviter),
      native: UserHandler.relationship_data(User.find_by(id: @entity.native_id))
    }
  end

  def meta_for_remote
    result = {
      agent_name: @entity.agent&.name
    }

    result[:image_path] = @entity.image.path unless @entity.image.blank?

    result
  end
end
