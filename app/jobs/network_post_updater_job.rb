# frozen_string_literal: true

# Synchronize updated post to main site
class NetworkPostUpdaterJob < ApplicationJob
  queue_as :default

  # @param [Integer] post_id
  def perform(post_id)
    @post = Post.find_by(id: post_id)

    return if @post.nil?

    NetworkManager::PostHandler.new.update_post(@post)
  end
end
