# frozen_string_literal: true
require 'google_drive'

class ::MentionableItems::GoogleSheets < ::MentionableItems::Source

  attr_reader :spreadsheet
  
  def initialize(spreadsheet)
    super

    if !spreadsheet
      access_token = MentionableItems::GoogleAuthorization.access_token
      return unless access_token.present?

      session = GoogleDrive::Session.from_access_token(access_token)
      spreadsheet_url = SiteSetting.mentionable_items_google_spreadsheet_url
      spreadsheet = session.spreadsheet_by_url(spreadsheet_url)
    end

    @spreadsheet = spreadsheet
  end

  def import_from_source
    @spreadsheet.worksheets.each do |worksheet|
      worksheet.list.each do |row|
        data = {}
        valid_keys = row.keys.select { |key| @keys.include?(key) }
        valid_keys.each do |key|
          data[key.to_sym] = row[key]
        end

        unless REQUIRED_KEYS.all? { |c| data.key?(c.to_sym) }
          @result.failed += 1
          next
        end

        add_result = MentionableItem.add!(data)

        case add_result
        when MentionableItem.import_result[:success]
          @result.successful += 1
        when MentionableItem.import_result[:failure]
          @result.failed += 1
        when MentionableItem.import_result[:duplicates]
          @result.duplicates += 1
        end
      end
    end
  end
end
