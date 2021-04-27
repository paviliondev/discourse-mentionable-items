# frozen_string_literal: true
require 'friendly_id'


class MentionableItemSlug < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name,
    use: :sequentially_slugged,
    slug_column: :name_slug
  belongs_to :mentionable_item

  def to_s
    self[:name_slug]
  end
end

# == Schema Information
#
# Table name: mentionable_item_slugs
#
#  id                  :bigint           not null, primary key
#  name_slug           :string
#  name                :string
#  mentionable_item_id :bigint
#
# Indexes
#
#  index_mentionable_item_slugs_on_mentionable_item_id  (mentionable_item_id)
#  index_mentionable_item_slugs_on_name_slug            (name_slug) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (mentionable_item_id => mentionable_items.id)
#
