# frozen_string_literal: true

class MentionableItem < ActiveRecord::Base

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

      unless !MentionableItem.find_by(url: mentionable_item[:url]).nil?
        begin
          self.create!(
            url: mentionable_item[:url],
            name: mentionable_item[:name],
            image_url: mentionable_item[:image_url],
            description:mentionable_item[:description],
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
