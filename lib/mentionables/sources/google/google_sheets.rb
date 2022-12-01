# frozen_string_literal: true
require "google/apis/sheets_v4"

class ::Mentionables::GoogleSheets < ::Mentionables::Source
  attr_reader :spreadsheet

  def initialize(spreadsheet = nil)
    super
    spreadsheet_result = spreadsheet.present? ? spreadsheet : request_spreadsheet

    @spreadsheet = spreadsheet_result
    @ready = true
  rescue => error
    Mentionables::Log.create(
      type: ::Mentionables::Log.types[:error],
      source: source_name,
      message: error
    )
  end

  def source_name
    'google_sheets'
  end

  def get_items_from_source
    spreadsheet_id = SiteSetting.mentionables_google_spreadsheet_id

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
      spreadsheet_id = SiteSetting.mentionables_google_spreadsheet_id
      return { error_key: 'no_spreadsheet_id' } if spreadsheet_id.blank?

      client = Google::Apis::SheetsV4::SheetsService.new

      client.authorization = Mentionables::GoogleAuthorization.authorizer

      client
    rescue => error
      Mentionables::Log.create(
        type: ::Mentionables::Log.types[:error],
        source: source_name,
        message: error
      )
    end
  end
end
