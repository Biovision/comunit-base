class EventMaterial < ApplicationRecord
  include Toggleable

  NAME_LIMIT = 250

  toggleable :show_on_page

  belongs_to :event

  mount_uploader :attachment, EventAttachmentUploader

  after_initialize { self.uuid = SecureRandom.uuid if uuid.nil? }

  validates_presence_of :name
  validates_length_of :name, maximum: NAME_LIMIT
  validates_length_of :description, maximum: NAME_LIMIT

  scope :ordered_by_name, -> { order('name asc') }
  scope :for_main_page, -> { where(show_on_page: true) }

  def self.page_for_administration
    ordered_by_name
  end

  def self.page_for_visitors
    for_main_page.ordered_by_name
  end

  def self.page_for_participants
    ordered_by_name
  end

  def self.entity_parameters
    %i(attachment name description show_on_page)
  end

  def self.creation_parameters
    entity_parameters + %i(event_id)
  end

  def locked?
    event.locked?
  end
end
