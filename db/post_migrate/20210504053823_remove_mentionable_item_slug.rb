# frozen_string_literal: true
class RemoveMentionableItemSlug < ActiveRecord::Migration[6.0]
  def up
    drop_table :mentionable_item_slugs
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
