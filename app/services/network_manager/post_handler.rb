# frozen_string_literal: true

# Synchronizing posts with central site
class NetworkManager::PostHandler < NetworkManager
  REMOTE_URL = "#{MAIN_HOST}/network/posts"

  # Create post on central site
  #
  # @param [Post] entity
  def create_remote(entity)
    log_event("[I] Creating remote post #{entity.id} (#{entity.uuid})")
    @entity = entity
    rest(:post, REMOTE_URL, data_for_remote)
  end

  # Update post on central site
  #
  # @param [Post] entity
  def update_remote(entity)
    log_event("[I] Updating remote post #{entity.id} (#{entity.uuid})")
    @entity = entity
    rest(:patch, "#{REMOTE_URL}/#{entity.uuid}", data_for_remote)
  end

  # Create local post from remote data
  def create_local
    uuid = @data.dig(:id)

    log_event "[I] Creating local post #{uuid}"

    @entity = Post.new(uuid: uuid)
    @entity.agent = Agent.named(@data.dig(:meta, :agent_name).to_s)

    apply_for_create

    log_event "[I] Validation status after create: #{@entity.valid?}"

    @entity.save
    @entity
  end

  private

  def apply_for_create
    assign_user_from_data
    assign_region_from_data
    apply_post_type
    apply_attributes
    apply_attachments
    assign_image_from_data
  end

  def apply_attributes
    permitted = %i[
      ip created_at updated_at show_owner translation time_required
      publication_time slug title image_alt_text image_name image_source_name
      image_source_link original_title source_name source_link meta_title
      meta_keywords meta_description author_name author_title author_url
      translator_name lead body parsed_body tags_cache region_id
    ]
    input = @data.dig(:attributes).to_h

    attributes = input.select { |a, _| permitted.include?(a.to_sym) }
    @entity.assign_attributes(attributes)
  end

  def apply_post_type
    type_data = @data.dig(:relationships, :post_type).to_h
    slug = type_data.dig(:attributes, :slug)
    type = PostType.find_by(id: type_data[:id]) || PostType.find_by(slug: slug)

    @entity.post_type = type
  end

  def apply_attachments
    relationships = @data.dig(:relationships).to_h
    @entity.data['comunit'] ||= {}
    @entity.data['comunit']['attachments'] = relationships.dig(:attachments)
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
    ignored = %w[
      id image agent_id user_id comments_count view_count upvote_count
      downvote_count vote_result region_id
    ]

    @entity.attributes.reject { |a, _| ignored.include?(a) }
  end

  # Relationship data in data.relationships block for remote create/update
  #
  # @return [Hash]
  def relationships_for_remote
    {
      user: UserHandler.relationship_data(@entity.user),
      region: RegionHandler.relationship_data(@entity.region),
      post_type: PostTypeHandler.relationship_data(@entity.post_type),
      attachments: attachments_for_remote
    }
  end

  # Attachments data in data.relationships block for remote create/update
  def attachments_for_remote
    @entity.post_attachments.map do |attachment|
      PostAttachmentHandler.relationship_data(attachment)
    end
  end

  def meta_for_remote
    result = {
      agent_name: @entity.agent&.name
    }

    result[:image_path] = @entity.image.path unless @entity.image.blank?

    result
  end
end
