# frozen_string_literal: true

# Add regions component to biovision_components
class AddRegionsComponent < ActiveRecord::Migration[5.2]
  def up
    criterion = {
      slug: Biovision::Components::RegionsComponent::SLUG
    }

    return if BiovisionComponent.where(criterion).exists?

    BiovisionComponent.create!(criterion)
  end

  def down
    # No rollback needed
  end
end
