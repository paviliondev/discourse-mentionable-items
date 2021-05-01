# frozen_string_literal: true
require 'google_drive'

class ::MentionableItems::GoogleSheets < ::MentionableItems::Source
  attr_reader :spreadsheet

  def initialize(spreadsheet = nil)
    super
    spreadsheet_result = spreadsheet.present? ? spreadsheet : request_spreadsheet

    if @spreadsheet&.class == ::GoogleDrive::Spreadsheet
      @spreadsheet = spreadsheet_result
      @ready = true
    else
      if spreadsheet_result.is_a?(Hash) && spreadsheet_result[:error_key]
        message = I18n.t("mentionable_items.google_sheets.#{spreadsheet_result[:error_key]}")
      elsif message = spreadsheet_result.try(:message)
        message = message
      else
        message = I18n.t("mentionable_items.google_sheets.failed_to_retrieve_spreadsheet")
      end

      MentionableItems::Log.create(
        type: ::MentionableItems::Log.types[:warn],
        source: source_name,
        message: message
      )
    end
  end

  def source_name
    'google_sheets'
  end

  def validate_item(item)
    if REQUIRED_KEYS.any? { |key| !item.has_key?(key.to_sym) }
      @result.missing_required += 1

      REQUIRED_KEYS.each do |key|
        if item[key.to_sym].present?
          @reuslt.missing_required_items << item[key.to_sym] 
        end
      end

      return false
    end

    if (item[:url] =~ URI::regexp).nil?
      @result.invalid_format += 1
      @reuslt.invalid_format_items << item[:url] if item[:url].present?
      return false
    end

    if MentionableItem.exists?(item.slice(*REQUIRED_KEYS.map(&:to_sym)))
      @result.duplicate += 1
      return false
    end

    return true
  end

  def import_from_source
    rows = @spreadsheet.worksheets.map { |w| w.list.map { |r| r } }.flatten
    @result.total = rows.size

    rows.each do |row|
      item = {}
      row_hash = row.to_hash.transform_keys(&:downcase)
      valid_keys = row_hash.keys.select { |key| KEYS.include?(key) }
      valid_keys.each { |key| item[key.to_sym] = row_hash[key] }

      next unless validate_item(item)

      if MentionableItem.create!(item)
        @result.success += 1
      else
        @result.failed_to_create += 1
      end  
    end
  end

  def request_spreadsheet
    begin
      access_token = MentionableItems::GoogleAuthorization.access_token
      return { error_key: 'failed_to_authorize' } if !access_token.present?

      spreadsheet_url = SiteSetting.mentionable_items_google_spreadsheet_url
      return { error_key: 'no_spreadsheet_url' } if !spreadsheet_url.present?

      session = GoogleDrive::Session.from_access_token(access_token)
      return { error_key: 'failed_to_create_session' } if !session.present?

      return session.spreadsheet_by_url(spreadsheet_url)
    rescue => error
      return error
    end
  end
end
