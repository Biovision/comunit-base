# frozen_string_literal: true

# Synchronize new post to main site
class NetworkPostPublisherJob < ApplicationJob
  queue_as :default

  # @param [Integer] post_id
  def perform(post_id)
    @post = Post.find_by(id: post_id)

    return if @post.nil?

    NetworkManager::PostHandler.new.create_post(@post)
  end
end
