# frozen_string_literal: true
require 'google_drive'

# All methods used to interact with external Google sheets
module ::MentionableItems::GoogleSheetOperations
  def self.ingest_sheet
    unless MentionableItems::GoogleAuthorization.authorized
      MentionableItems::GoogleAuthorization.get_access_token
    end

    session = GoogleDrive::Session.from_access_token(MentionableItems::GoogleAuthorization.access_token[:token])

    spreadsheet = session.spreadsheet_by_title(SiteSetting.mentionable_items_spreadsheet_name)
  
    worksheets = spreadsheet.worksheets[0..SiteSetting.mentionable_items_number_of_worksheets-1]

    MentionableItems::WorksheetsImport.import_sheets(worksheets)
  end
end
