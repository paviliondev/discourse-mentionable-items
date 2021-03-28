# frozen_string_literal: true

class CreateMentionableItems < ActiveRecord::Migration[5.2]
  def up
    create_table :mentionable_items do |t|
      t.string :url, null: false
      t.string :name
      t.string :image_url
      t.string :description
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :mentionable_items, :url, unique: true
  end

  def down
    drop_table :mentionable_items
  end
end
