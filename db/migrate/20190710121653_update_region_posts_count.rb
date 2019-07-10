# frozen_string_literal: true

# Update posts_count for regions
class UpdateRegionPostsCount < ActiveRecord::Migration[5.2]
  def up
    Post.where('region_id is not null').pluck(:region_id).each do |id|
      Region.update_post_count(nil, id)
    end
  end

  def down
    Post.where('region_id is not null').pluck(:region_id).each do |id|
      Region.update_post_count(id, nil)
    end
  end
end
