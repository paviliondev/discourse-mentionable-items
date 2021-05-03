# frozen_string_literal: true

class MentionableItem < ActiveRecord::Base
  has_one :mentionable_item_slug, dependent: :destroy
  validates_uniqueness_of :url

  before_create do
    if SiteSetting.mentionable_items_onebox_fallback
      apply_onebox_fallback
    end
  end

  after_create do
    if mentionable_item_slug.try(:name) != name
      new_slug = MentionableItemSlug.create(
        name: name,
        mentionable_item_id: self.id
      )
      self.name_slug = new_slug.name_slug
      self.save!
    end
  end

  def self.remove!(item)
    MentionableItem
      .where(url: item[:url])
      .destroy_all
  end

  def apply_onebox_fallback
    preview = Oneboxer.preview(self.url)
    document = Nokogiri::HTML(preview)

    return if document.nil?

    [:image_url, :name, :description].each do |key|
      value = self.send(key)

      if value.blank?
        if key == :image_url
          value = document.css('.thumbnail').attr('src')
        elsif key == :name
          value = document.css('h3 a').inner_html
        elsif key == :description
          value = document.css('p').inner_html
        end

        self.send("#{key.to_s}=", value) if value.present?
      end
    end
  end
end

# == Schema Information
#
# Table name: mentionable_items
#
#  id                  :bigint           not null, primary key
#  url                 :string           not null
#  name                :string           not null
#  name_slug           :string
#  image_url           :string
#  description         :string
#  affiliate_snippet_1 :string
#  affiliate_snippet_2 :string
#  affiliate_snippet_3 :string
#  created_at          :datetime
#  updated_at          :datetime
#
# Indexes
#
#  index_mentionable_items_on_name_slug  (name_slug)
#  index_mentionable_items_on_url        (url) UNIQUE
#
