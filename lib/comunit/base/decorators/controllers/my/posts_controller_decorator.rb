# frozen_string_literal: true

My::PostsController.class_eval do
  # post /my/posts
  def create
    @entity = Post.new(creation_parameters)
    if component_handler.allow_post_type?(@entity.post_type) && @entity.save
      apply_post_tags
      apply_post_categories
      PostBodyParserJob.perform_later(@entity.id)
      NetworkPostSyncJob.perform_later(@entity.id, false)
      form_processed_ok(my_post_path(id: @entity.id))
    else
      form_processed_with_error(:new)
    end
  end

  # patch /my/posts/:id
  def update
    if @entity.update(entity_parameters)
      apply_post_tags
      apply_post_categories
      PostBodyParserJob.perform_later(@entity.id)
      NetworkPostSyncJob.perform_later(@entity.id, true)
      form_processed_ok(my_post_path(id: @entity.id))
    else
      form_processed_with_error(:edit)
    end
  end
end
