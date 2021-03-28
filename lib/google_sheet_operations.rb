# frozen_string_literal: true

# All methods used to interact with external Google sheets
module ::MentionableItems::GoogleSheetOperations
  def self.ingest_sheet
    unless MentionableItems::GoogleAuthorization.authorized
      MentionableItems::GoogleAuthorization.get_access_token
    end

    session = GoogleDrive::Session.from_access_token(MentionableItems::GoogleAuthorization.access_token[:token])

    spreadsheet = session.spreadsheet_by_title(SiteSetting.mentionable_items_spreadsheet_name)
  
    worksheets = spreadsheet.worksheets[0..SiteSetting.mentionable_items_number_of_worksheets-1]

    worksheets.each do |sheet|
      sheet_meta = {
        "url": true,
        "image_url": true,
        "name": true,
        "description": true,
      }
      column = 1
      while column <= SiteSetting.mentionable_items_worksheet_max_column do
        if sheet_meta[sheet[1, column].downcase.to_sym]
          sheet_meta[sheet[1, column].downcase.to_sym] = column
        end
        column += 1
      end
      this_url, this_image_url, this_name, this_description = 0, 0, 0, 0 # cannot create variables dynamically in Ruby using eval
      row = 2
      while row <= SiteSetting.mentionable_items_worksheet_max_row do
        blank = true
        sheet_meta.each do |key|
          eval("this_#{key[0].to_s}=nil")
          if sheet_meta[key[0].to_sym] != true && !eval("this_#{key[0].to_s}=sheet[row, sheet_meta[key[0].to_sym]]").blank?
            blank = false
          end
        end
        if !blank
          MentionableItem.add!(url: this_url, image_url: this_image_url, name: this_name, description: this_description)
        end
        row += 1
      end
    end
  end
end
