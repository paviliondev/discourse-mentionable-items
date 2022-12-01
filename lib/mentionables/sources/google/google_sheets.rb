# frozen_string_literal: true
#require 'google_drive'
require "google/apis/sheets_v4"

class ::Mentionables::GoogleSheets < ::Mentionables::Source
  attr_reader :spreadsheet

  def initialize(spreadsheet = nil)
    super
    spreadsheet_result = spreadsheet.present? ? spreadsheet : request_spreadsheet

    # if spreadsheet_result&.class == ::GoogleDrive::Spreadsheet
    @spreadsheet = spreadsheet_result
    @ready = true
    # else
    #   if spreadsheet_result.is_a?(Hash) && spreadsheet_result[:error_key]
    #     message = I18n.t("mentionables.google_sheets.#{spreadsheet_result[:error_key]}")
    #   elsif message = spreadsheet_result.try(:message)
    #     message = message
    #   else
    #     message = I18n.t("mentionables.google_sheets.failed_to_retrieve_spreadsheet")
    #   end
  # rescue => error
  #   Mentionables::Log.create(
  #     type: ::Mentionables::Log.types[:error],
  #     source: source_name,
  #     message: error
  #   )
  end

  def source_name
    'google_sheets'
  end

  def get_items_from_source
    spreadsheet_id = SiteSetting.mentionables_google_spreadsheet_id
    # worksheets = @spreadsheet.sheets

    # client.get_spreadsheet_values(spreadsheet_id, "Sheet1!A1:D1000")

    # if (gids = SiteSetting.mentionables_google_worksheet_gids.split('|')).any?
    #   worksheets = worksheets.select { |w| gids.include?(w.gid) }
    # end

    sheets = SiteSetting.mentionables_google_worksheet_names.split('|')

    items = []

    sheets.each do |sheet|
      data = spreadsheet.get_spreadsheet_values(spreadsheet_id, "#{sheet}!A1:H#{SiteSetting.mentionables_google_worksheet_max_row}").values
      valid_columns = []
      column_keys = []
      data.each_with_index do |row, index|
        if index == 0
          row.each_with_index do |value, column_index|
            if KEYS.include?(value)
              valid_columns.push(column_index)
            end
            column_keys.push(value)
          end
        else
          item = {}
          row.each_with_index do |value, column_index|
            if valid_columns.include?(column_index)
              item[column_keys[column_index].to_sym] = value
            end
          end
          if !item.empty?
            items.push(item)
          end
        end
      end
    end

    items
  end

  def request_spreadsheet
    begin
      # access_token = Mentionables::GoogleAuthorization.access_token
      # return { error_key: 'failed_to_authorize' } if !access_token.present?

      spreadsheet_id = SiteSetting.mentionables_google_spreadsheet_id
      return { error_key: 'no_spreadsheet_id' } if spreadsheet_id.blank?

      client = Google::Apis::SheetsV4::SheetsService.new

      client.authorization = Mentionables::GoogleAuthorization.authorizer

      client
    # rescue => error
    #   Mentionables::Log.create(
    #     type: ::Mentionables::Log.types[:error],
    #     source: source_name,
    #     message: error
    #   )
    end
  end
end
