class Site < ApplicationRecord
  mount_uploader :image, SiteImageUploader

  has_many :users, dependent: :nullify

  def self.synchronization_parameters
    ignored = %w(id users_count)
    column_names.reject { |c| ignored.include?(c) }
  end
end
