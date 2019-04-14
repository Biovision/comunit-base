# frozen_string_literal: true

# Synchronizing posts with central site
class NetworkManager::PostHandler < NetworkManager
  # @param [Post] entity
  def create_post(entity)
    log_event("Creating post #{entity.id} (#{entity.uuid})")
    @entity = entity
    url = "#{MAIN_HOST}/api/posts"
    rest_post(url, prepare_entity_data)
  end

  # @param [Post] entity
  def update_post(entity)
    log_event("Updating post #{entity.id} (#{entity.uuid})")
    @entity = entity
    url = "#{MAIN_HOST}/api/posts/#{entity.uuid}"
    rest_patch(url, prepare_entity_data)
  end

  private

  def prepare_entity_data
    ignored = %w[image agent_id user_id comments_count view_count upvote_cound downvote_count vote_result]
    attributes = @entity.attributes.reject { |a| ignored.include?(a) }

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
          attachments: []
        },
        meta: {
          agent_name: @entity.agent&.name
        },
      },
    }

    data[:data][:meta][:image_path] = @entity.image.path unless @entity.image.blank?

    @entity.post_attachments.each do |attachment|
      data[:data][:relationships][:attachments] << {
        id: attachment.uuid,
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
