# frozen_string_literal: true
require 'google_drive'

class ::Mentionables::GoogleSheets < ::Mentionables::Source
  attr_reader :spreadsheet

  def initialize(spreadsheet = nil)
    super
    spreadsheet_result = spreadsheet.present? ? spreadsheet : request_spreadsheet

    if spreadsheet_result&.class == ::GoogleDrive::Spreadsheet
      @spreadsheet = spreadsheet_result
      @ready = true
    else
      if spreadsheet_result.is_a?(Hash) && spreadsheet_result[:error_key]
        message = I18n.t("mentionables.google_sheets.#{spreadsheet_result[:error_key]}")
      elsif message = spreadsheet_result.try(:message)
        message = message
      else
        message = I18n.t("mentionables.google_sheets.failed_to_retrieve_spreadsheet")
      end

      Mentionables::Log.create(
        type: ::Mentionables::Log.types[:warning],
        source: source_name,
        message: message
      )
    end
  end

  def source_name
    'google_sheets'
  end

  def get_items_from_source
    worksheets = @spreadsheet.worksheets

    if (gids = SiteSetting.mentionables_google_worksheet_gids.split('|')).any?
      worksheets = worksheets.select { |w| gids.include?(w.gid) }
    end

    rows = worksheets.map { |w| w.list.map { |r| r } }.flatten
    items = []

    rows.each do |row|
      item = {}
      row_hash = row.to_hash.transform_keys(&:downcase)
      valid_keys = row_hash.keys.select { |key| KEYS.include?(key) }
      valid_keys.each { |key| item[key.to_sym] = row_hash[key] }
      items.push(item)
    end

    items
  end

  def request_spreadsheet
    begin
      access_token = Mentionables::GoogleAuthorization.access_token
      return { error_key: 'failed_to_authorize' } if !access_token.present?

      spreadsheet_url = SiteSetting.mentionables_google_spreadsheet_url
      return { error_key: 'no_spreadsheet_url' } if !spreadsheet_url.present?

      session = GoogleDrive::Session.from_access_token(access_token)
      return { error_key: 'failed_to_create_session' } if !session.present?

      session.spreadsheet_by_url(spreadsheet_url)
    rescue => error
      error
    end
  end
end
