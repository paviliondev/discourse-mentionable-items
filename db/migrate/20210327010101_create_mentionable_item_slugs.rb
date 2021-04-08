class CreateMentionableItemSlugs < ActiveRecord::Migration[5.2]
  def up
    create_table :mentionable_item_slugs do |t|
      t.string :name_slug
      t.string :name
    end
    add_index :mentionable_item_slugs, :name_slug, unique: true
    add_reference :mentionable_item_slugs, :item, polymorphic: true, index: true
  end
  def down
    drop_table :mentionable_item_slugs
  end
end