# frozen_string_literal: true

# Synchronizing posts with central site
class NetworkManager::PostHandler < NetworkManager
  # @param [Post] entity
  def create_post(entity)
    log_event("Creating post #{entity.id} (#{entity.uuid})")
    @entity = entity
    url = "#{MAIN_HOST}/network/posts"
    rest_post(url, prepare_entity_data)
  end

  # @param [Post] entity
  def update_post(entity)
    log_event("Updating post #{entity.id} (#{entity.uuid})")
    @entity = entity
    url = "#{MAIN_HOST}/network/posts/#{entity.uuid}"
    rest_patch(url, prepare_entity_data)
  end

  def accept_post
    uuid = @data.dig(:id)

    log_event "Creating post #{uuid}"

    @post = Post.new(uuid: uuid)
    @post.agent = Agent.named(@data.dig(:meta, :agent_name).to_s)

    apply_for_create

    log_event "Validation status after create: #{@post.valid?}"

    @post.save
    @post
  end

  private

  def apply_for_create
    apply_owner
    apply_post_type
    apply_attributes
    apply_attachments
    apply_image
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
    @post.assign_attributes(attributes)
  end

  def apply_post_type
    type_data = @data.dig(:relationships, :post_type).to_h
    slug = type_data.dig(:attributes, :slug)
    type = PostType.find_by(id: type_data[:id]) || PostType.find_by(slug: slug)

    @post.post_type = type
  end

  def apply_owner
    user_data = @data.dig(:relationships, :user).to_h
    slug = user_data.dig(:attributes, :slug)
    user = User.find_by(uuid: user_data[:id]) || User.find_by(slug: slug)

    @post.user = user
  end

  def apply_attachments
    relationships = @data.dig(:relationships).to_h
    @post.data['comunit'] ||= {}
    @post.data['comunit']['attachments'] = relationships.dig(:attachments)
  end

  def apply_image
    image_path = @data.dig(:meta, :image_path)

    return if image_path.blank? || !File.exist?(image_path)

    @post.image = Pathname.new(image_path).open
  end

  def prepare_entity_data
    ignored = %w[
      image agent_id user_id comments_count view_count
      upvote_count downvote_count vote_result
    ]

    attributes = @entity.attributes.reject { |a, _| ignored.include?(a) }

    data = {
      data: {
        id: @entity.uuid,
        type: @entity.class.table_name,
        attributes: attributes,
        relationships: {
          user: {
            id: @entity.user&.uuid,
            type: User.table_name,
            attributes: {
              slug: @entity.user&.slug
            }
          },
          post_type: {
            id: @entity.post_type_id,
            type: PostType.table_name,
            attributes: {
              slug: @entity.post_type.slug
            }
          },
          attachments: []
        },
        meta: {
          agent_name: @entity.agent&.name
        }
      }
    }

    data[:data][:meta][:image_path] = @entity.image.path unless @entity.image.blank?

    @entity.post_attachments.each do |attachment|
      data[:data][:relationships][:attachments] << {
        id: attachment.id,
        type: attachment.class.table_name,
        attributes: {
          name: attachment.name
        },
        meta: {
          file_path: attachment.file.path
        }
      }
    end

    data
  end
end
