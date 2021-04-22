class CreateMentionableItemsNameSlugIndex < ActiveRecord::Migration[5.2]
  def up
    add_index :mentionable_items, :name_slug, unique: true
  end
  def down
    remove_index :mentionable_items, :name_slug
  end
end