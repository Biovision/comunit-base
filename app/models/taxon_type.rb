# frozen_string_literal: true

# Taxon type
# 
# Attributes:
#   active [Boolean]
#   created_at [DateTime]
#   data [jsonb]
#   name [string]
#   slug [string]
#   updated_at [DateTime]
#   uuid [uuid]
class TaxonType < ApplicationRecord
  include BelongsToSite
  include Checkable
  include HasUuid
  include RequiredUniqueSlug
  include Toggleable

  toggleable :active

  has_many :taxa, dependent: :delete_all
  has_many :taxon_type_users, dependent: :delete_all

  validates_presence_of :name

  scope :active, -> { where(active: true) }
  scope :list_for_administration, -> { order('name asc, slug asc') }

  # @param [String] slug
  def self.[](slug)
    find_by(slug: slug)
  end

  def self.entity_parameters
    %i[active name slug]
  end

  def text_for_link
    name
  end

  # @param [User] user
  def user?(user)
    taxon_type_users.owned_by(user).exists?
  end

  # @param [User] user
  def add_user(user)
    return if user.nil?

    taxon_type_users.create(user: user)
  end

  # @param [User] user
  def remove_user(user)
    return if user.nil?

    taxon_type_users.owned_by(user).delete_all
  end

  # @param [User] user
  def taxon_ids_for_user(user)
    list = taxa.joins(:taxon_users).where(taxon_users: { user_id: user&.id })
    list.pluck(:id, :children_cache).flatten.uniq
  end
end
