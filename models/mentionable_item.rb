# frozen_string_literal: true

class MentionableItem < ActiveRecord::Base
  has_one :mentionable_item_slug, dependent: :destroy

  after_create do
    if mentionable_item_slug.try(:name) != name
      new_slug = MentionableItemSlug.create(name: name,  mentionable_item_id: self.id)
      self.name_slug = new_slug.name_slug
      self.save!
    end
  end

  SUCCESS = 1
  FAILURE = 0

  def self.add!(mentionable_item)

    unless (!mentionable_item.has_key?(:url) || (mentionable_item[:url] =~ URI::regexp).nil?)

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

      unless !MentionableItem.find_by(url: mentionable_item[:url]).nil?
        begin
          self.create!(
            url: mentionable_item[:url],
            name: mentionable_item[:name],
            image_url: mentionable_item[:image_url],
            description: mentionable_item[:description],
            affiliate_snippet_1: mentionable_item[:affiliate_snippet_1],
            affiliate_snippet_2: mentionable_item[:affiliate_snippet_2],
            affiliate_snippet_3: mentionable_item[:affiliate_snippet_3],
            created_at:  Time.zone.now,
            updated_at: Time.zone.now,
          )
          return SUCCESS
        rescue
          return FAILURE
        end
      else
        puts I18n.t('sheet_ingest.warnings.duplicate_url')
        return FAILURE
      end
    else
      puts I18n.t('sheet_ingest.warnings.no_valid_url')
      return FAILURE
    end
  end

  def self.remove!(mentionable_item)
    MentionableItem
      .where(url: mentionable_item[:url])
      .destroy_all
  end
end
