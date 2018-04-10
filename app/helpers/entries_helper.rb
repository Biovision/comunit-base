module EntriesHelper
  # @param [String] text
  # @param [Integer] passages
  def preview(text, passages = 2)
    text.split("</p>\n<p>")[0...passages].join('</p><p>')
  end

  # @param [String] text
  # @param [Integer] letters
  def glimpse(text, letters = 140)
    strip_tags(text).gsub(/(\S{20})/, '\1 ').strip[0..letters] + '…'
  end

  # @param [News] entity
  def admin_news_link(entity)
    link_to(entity.title, admin_news_path(id: entity.id))
  end

  # @param [News] news
  # @param [String] text
  # @param [Hash] options
  def news_link(news, text = news&.title, options = {})
    if news.class.to_s == News.to_s
      parameters = { category_slug: news.news_category&.slug, slug: news.slug }
      if news.news_category.nil?
        text
      else
        if news.regional?
          link_to text, news_in_category_regional_news_index_path(parameters), options
        else
          link_to text, news_in_category_news_index_path(parameters), options
        end
      end
    else
      '—'
    end
  end

  # @param [Post] entity
  # @param [String] text
  def post_link(entity, text = entity&.title, options = {})
    if entity.class.to_s == Post.to_s
      if entity.post_category.class.to_s == PostCategory.to_s
        parameters = { category_slug: entity.post_category.slug, slug: entity.slug }
        link_to text, post_in_category_posts_path(parameters)
      else
        text
      end
    elsif entity.class.to_s == News.to_s
      parameters = { category_slug: entity.news_category&.slug, slug: entity.slug }
      if entity.news_category.nil?
        text
      else
        if entity.regional?
          link_to text, news_in_category_regional_news_index_path(parameters), options
        else
          link_to text, news_in_category_news_index_path(parameters), options
        end
      end
    else
      '—'
    end
  end

  def link_to_commentable(commentable, user)
    case commentable.class.to_s
      when Entry.to_s
        entry_link(commentable, user)
      when Post.to_s
        post_link(commentable)
      when News.to_s
        news_link(commentable)
      else
        commentable.class.to_s
    end
  end

  # @param [Entry] entry
  # @param [User] user
  # @param [String] text
  # @param [Hash] options
  def entry_link(entry, user, text = entry.title, options = {})
    if entry.visible_to? user
      link_to (text || t(:untitled)), entry_path({ id: entry.id }.merge(options))
    else
      raw "<span class=\"not-found\">[entry #{entry.id}]</span>"
    end
  end

  # @param [Entry] entry
  def admin_entry_link(entry)
    link_to (entry.title || t(:untitled)), admin_entry_path(id: entry.id)
  end

  # @param [String] name
  # @param [String] url
  def source_link(name, url)
    if url.blank?
      name
    else
      link_to(name.blank? ? URI.parse(url).host : name, url, rel: 'external')
    end
  end
end