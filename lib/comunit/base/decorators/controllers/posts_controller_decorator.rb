# frozen_string_literal: true

PostsController.class_eval do
  # post /posts
  def create
    @entity = Post.new(creation_parameters)
    if @entity.save
      apply_post_tags
      apply_post_categories
      add_attachments if params.key?(:post_attachment)
      mark_as_featured if params[:featured]
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

  def legacy_show
    @entity = Post.list_for_visitors.find_by(slug: params[:slug])
    if @entity.nil?
      handle_http_404("Cannot find non-deleted post #{params[:id]}")
    else
      @entity.increment :view_count
      @entity.increment :rating, 0.0025
      @entity.save

      render :show
    end
  end
end
