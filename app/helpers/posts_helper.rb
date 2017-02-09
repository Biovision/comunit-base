module PostsHelper
  # @param [NewsCategory] category
  def admin_news_category_link(category)
    link_to(category.name, admin_news_category_path(category.id))
  end

  # @param [PostCategory] category
  def admin_post_category_link(category)
    link_to(category.full_title, admin_post_category_path(category.id))
  end

  # @param [NewsCategory] category
  # @param [String] text
  def news_category_link(category, text = category&.name)
    if category.is_a? NewsCategory
      parameters = { category_slug: category.slug }
      link_to text, category_news_index_path(parameters)
    else
      ''
    end
  end

  # @param [NewsCategory] category
  # @param [String] text
  def regional_news_category_link(category, text = category&.name)
    if category.is_a? NewsCategory
      parameters = { category_slug: category.slug }
      link_to text, category_regional_news_index_path(parameters)
    else
      ''
    end
  end

  # @param [PostCategory] category
  # @param [String] text
  def post_category_link(category, text = category&.name)
    if category.is_a? PostCategory
      parameters = { category_slug: category.slug }
      link_to text, category_posts_path(parameters)
    else
      ''
    end
  end

  def post_types_for_select
    News.post_types.keys.map { |post_type| [t("activerecord.attributes.news.post_types.#{post_type}"), post_type] }
  end

  # @param [PostCategory] selected_category
  def post_categories_for_site(selected_category)
    options = [[t(:not_set), '']]
    PostCategory.for_tree.visible.each do |category|
      options << [category.name, category.id]
      if category.children.visible.any?
        PostCategory.for_tree(category).visible.each do |subcategory|
          options << ["-#{subcategory.name}", subcategory.id]
          if subcategory.children.visible.any?
            PostCategory.for_tree(subcategory).visible.each do |deep_category|
              options << ["--#{deep_category.name}", deep_category.id]
            end
          end
        end
      end
    end
    selected = selected_category.nil? ? nil : selected_category.id
    options_for_select(options, selected)
  end

  # @param [NewsCategory] selected_category
  def news_categories_for_site(selected_category)
    options = [[t(:not_set), '']]
    NewsCategory.visible.ordered_by_priority.each do |category|
      options << [category.name, category.id]
    end
    selected = selected_category.nil? ? nil : selected_category.id
    options_for_select(options, selected)
  end

  # @param [PostCategory] selected_category
  def post_categories_for_select(user)
    options = []
    PostCategory.for_tree.for_editor(user).each do |category|
      options << [category.name, category.id]
      if category.children.for_editor(user).any?
        PostCategory.for_tree(category).for_editor(user).each do |subcategory|
          options << ["-#{subcategory.name}", subcategory.id]
          if subcategory.children.for_editor(user).any?
            PostCategory.for_tree(subcategory).for_editor(user).each do |deep_category|
              options << ["--#{deep_category.name}", deep_category.id]
            end
          end
        end
      end
    end
    options
  end

  # @param [User] user
  def news_categories_for_select(user)
    NewsCategory.for_editor(user).each.map do |category|
      [category.name, category.id]
    end
  end
end
