# frozen_string_literal: true

class MentionableItem < ActiveRecord::Base

  def self.add!(mentionable_item)

    if !mentionable_item.has_key?(:image_url) || mentionable_item.has_key?(:image_url) && mentionable_item[:image_url].blank?
      document = Nokogiri::HTML(Oneboxer.preview(mentionable_item[:url]))
      mentionable_item[:image_url] = document.css('.thumbnail').attr('src').value
    end

    self.create!(
      url: mentionable_item[:url],
      name: mentionable_item[:name],
      image_url: mentionable_item[:image_url],
      description:mentionable_item[:description],
      created_at:  Time.zone.now,
      updated_at: Time.zone.now,
    )
  end

  def self.remove!(mentionable_item)
    mentionable_item
      .where(url: mentionable_item.url)
      .delete!
  end
end
