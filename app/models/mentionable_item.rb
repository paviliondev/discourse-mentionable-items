# frozen_string_literal: true

class MentionableItem < ActiveRecord::Base
  has_one :mentionable_item_slug, dependent: :destroy

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

  def self.import_result
    @import_result ||= Enum.new(
      success: 0,
      failure: 1,
      duplicate: 2
    )
  end

  def self.add!(mentionable_item)
    if !mentionable_item.has_key?(:url) || (mentionable_item[:url] =~ URI::regexp).nil?
      return import_result[:failure]
    end

    if MentionableItem.find_by(url: mentionable_item[:url])
      return import_result[:duplicate]
    end

    if SiteSetting.mentionable_items_onebox_fallback
      mentionable_item = apply_onebox_fallback(mentionable_item)
    end

    begin
      create!(mentionable_item)
      import_result[:success]
    rescue
      import_result[:failure]
    end
  end

  def self.remove!(mentionable_item)
    MentionableItem
      .where(url: mentionable_item[:url])
      .destroy_all
  end

  def self.apply_onebox_fallback(mentionable_item)
    if !mentionable_item.has_key?(:image_url) || mentionable_item.has_key?(:image_url) && mentionable_item[:image_url].blank?
      document = Nokogiri::HTML(Oneboxer.preview(mentionable_item[:url]))
      unless document.nil? || document.css('.thumbnail').attr('src').nil?
        mentionable_item[:image_url] = document.css('.thumbnail').attr('src').value
      end
    end

    if !mentionable_item.has_key?(:name) || mentionable_item.has_key?(:name) && mentionable_item[:name].blank?
      document = Nokogiri::HTML(Oneboxer.preview(mentionable_item[:url]))
      unless document.nil? || document.css('h3 a').inner_html.nil?
        mentionable_item[:name] = document.css('h3 a').inner_html
      end
    end

    if !mentionable_item.has_key?(:description) || mentionable_item.has_key?(:description) && mentionable_item[:description].blank?
      document = Nokogiri::HTML(Oneboxer.preview(mentionable_item[:url]))
      unless document.nil? || document.css('p').inner_html.nil?
        mentionable_item[:description] = document.css('p').inner_html
      end
    end
    
    mentionable_item
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
