module ParsingHelper
  # Prepare post text for views
  #
  # @param [Post] post
  # @return [String]
  def prepare_post_text(post)
    entry = post.entry
    raw(entry.nil? ? post.body : entry.body)
  end
end
