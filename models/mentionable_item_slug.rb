require 'friendly_id'

# frozen_string_literal: true

class MentionableItemSlug < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name,
    use: :sequentially_slugged,
    slug_column: :name_slug
  belongs_to :mentionable_item, polymorphic: true

  def to_s
    self[:name_slug]
  end
end
