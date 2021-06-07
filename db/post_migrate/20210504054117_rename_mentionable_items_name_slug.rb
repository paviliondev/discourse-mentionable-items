# frozen_string_literal: true
class RenameMentionableItemsNameSlug < ActiveRecord::Migration[6.0]
  def change
    rename_column :mentionable_items, :name_slug, :slug
    add_index :mentionable_items, :slug, unique: true
  end
end
