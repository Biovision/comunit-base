module ParsingHelper
  # Prepare post text for views
  #
  # @param [Post] post
  # @return [String]
  def prepare_post_text(post)
    entry = post.entry
    raw(entry.nil? ? post.body : entry.body)
  end

  # Prepare comment text for views
  #
  # @param [Comment] comment
  # @return [String]
  def prepare_comment_text(comment)
    simple_format comment.body
    # raw comment.body.split("\n").map(&:squish).reject(&:blank?).map { |s| parse_common_string s }.join
  end

  # Parse fragments like [post 123](link text)
  #
  # @param [String] string
  # @return [String]
  def parse_post_links(string)
    pattern = Post::LINK_PATTERN
    string.gsub pattern do |chunk|
      match = pattern.match chunk
      post  = Post.visible.find_by id: match[:id]
      if post.is_a? Post
        link_text = match[:text].blank? ? post.title : match[:text]
        link_tag  = link_to(link_text, post, title: post.title)
        "<cite>#{link_tag}</cite>"
      else
        '<span class="not-found">post ' + match[:id] + '</span>'
      end
    end
  end

  def parse_figure_links(post, string)
    pattern = Figure::LINK_PATTERN
    string.gsub pattern do |chunk|
      match  = pattern.match chunk
      figure = post.figures.find_by(slug: match[:id])
      if figure.is_a? Figure
        image   = image_tag(figure.image.big.url, alt: figure.text_for_alt)
        caption = figure.caption.blank? ? '' : "<figcaption>#{figure.caption}</figcaption>"
        "<figure>#{image}#{caption}</figure>\n"
      else
        '<figure><span class="not-found">figure ' + match[:id] + "</span></figure>\n"
      end
    end
  end

  protected

  def parse_post_string(post, string)
    if string =~ Figure::LINK_PATTERN
      parse_figure_links post, string
    else
      string[0] == '<' ? string : "<p>#{string}</p>"
    end
  end

  # Parse string as string from common text
  #
  # @param [String] string
  # @return [String]
  def parse_common_string(string)
    "<p>#{fragments_for_string(string)}</p>\n"
  end

  # Parse fragments available for common texts
  #
  # @param [String] string
  # @return [String]
  def fragments_for_string(string)
    quoted_string = string.gsub('<', '&lt;').gsub('>', '&gt;')
    parse_post_links quoted_string
  end
end
