# frozen_string_literal: true

PostsController.class_eval do
  # post /posts
  def create
    @entity = Post.new(creation_parameters)
    if @entity.save
      apply_post_tags
      apply_post_categories
      add_attachments if params.key?(:post_attachment)
      PostBodyParserJob.perform_later(@entity.id)
      NetworkPostSyncJob.perform_later(@entity.id, false)
      form_processed_ok(PostManager.new(@entity).post_path)
    else
      form_processed_with_error(:new)
    end
  end

  # patch /posts/:id
  def update
    if @entity.update(entity_parameters)
      apply_post_tags
      apply_post_categories
      add_attachments if params.key?(:post_attachment)
      PostBodyParserJob.perform_later(@entity.id)
      NetworkPostSyncJob.perform_later(@entity.id, true)
      form_processed_ok(PostManager.new(@entity).post_path)
    else
      form_processed_with_error(:edit)
    end
  end
end
