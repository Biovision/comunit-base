class City < ApplicationRecord
  belongs_to :region

  before_validation { self.name = name.strip unless name.nil? }
  validates_presence_of :name
  validates_uniqueness_of :name, scope: [:region]

  scope :ordered_by_name, -> { order('name asc') }
  scope :visible, -> { where(deleted: false) }

  def self.page_for_administration
    ordered_by_name
  end

  def self.page_for_user
    visible.ordered_by_name
  end

  def self.entity_parameters
    %i(name)
  end

  def self.creation_parameters
    entity_parameters + %i(region_id)
  end
end
