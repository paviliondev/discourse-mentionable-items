# frozen_string_literal: true
require_relative '../../plugin_helper'
# require 'rspec-mocks'

describe ::Mentionables::GoogleSheets do
  FIXTURE_PATH = "#{Rails.root}/plugins/discourse-mentionables/spec/fixtures"

  before(:all) do
    SiteSetting.mentionables_onebox_fallback = false
  end
  context "spreadsheet has required columns" do
    it "Importing a sheet with required columns works" do
      SiteSetting.mentionables_google_spreadsheet_id = "invented"
      Mentionables::GoogleAuthorization.stubs(:authorizer).returns(Google::Auth::ServiceAccountCredentials.new)
      Google::Apis::SheetsV4::SheetsService.any_instance.stubs(:get_spreadsheet_values).returns(stub('values',
        values: [["url"],
        ["https://example.com/tomato"],
        ["https://example.com/tomato"],
        ["https://example.com/tomato"]]
      ))

      workbook = ::Mentionables::GoogleSheets.new
      workbook.request_spreadsheet
      result = workbook.import

      expect(result.success).to eq(3)
      expect(result.error).to eq(0)
      expect(result.duplicate).to eq(0)
      expect(MentionableItem.all.size).to eq(3)
    end
  end

  context "spreadsheet has optional columns" do
    it "Importing a sheet with optional columns works" do
      SiteSetting.mentionables_google_spreadsheet_id = "invented"
      Mentionables::GoogleAuthorization.stubs(:authorizer).returns(Google::Auth::ServiceAccountCredentials.new)
      Google::Apis::SheetsV4::SheetsService.any_instance.stubs(:get_spreadsheet_values).returns(stub('values',
        values: [["name", "url", "description", "affiliate_snippet_1"],
        ["Tomato", "https://example.com/tomato", "A Tomato", "<div>Tomato</div>"],
        ["Orange", "https://example.com/tomato", "An Orange", "<div>Orange</div>"],
        ["Cucumber", "https://example.com/tomato", "A Cucumber", "<div>Cucumber</div>"]]
      ))

      workbook = ::Mentionables::GoogleSheets.new
      workbook.request_spreadsheet
      result = workbook.import

      expect(result.success).to eq(3)
      expect(result.error).to eq(0)
      expect(result.duplicate).to eq(0)
      expect(MentionableItem.all.size).to eq(3)
    end
  end

  context "Importing an empty sheet does nothing" do
    it "Importing a sheet with no columns does nothing" do
      SiteSetting.mentionables_google_spreadsheet_id = "invented"
      Mentionables::GoogleAuthorization.stubs(:authorizer).returns(Google::Auth::ServiceAccountCredentials.new)
      Google::Apis::SheetsV4::SheetsService.any_instance.stubs(:get_spreadsheet_values).returns(stub('values',
        values: []
      ))

      workbook = ::Mentionables::GoogleSheets.new
      workbook.request_spreadsheet
      result = workbook.import

      expect(result.success).to eq(0)
      expect(result.error).to eq(0)
      expect(result.duplicate).to eq(0)
      expect(MentionableItem.all.size).to eq(0)
    end
  end

    # it "Importing a sheet with optional columns works" do
    #   spreadsheet = create_spreadsheet("required_and_optional")
    #   result = described_class.new(spreadsheet).import
  
    #   expect(result.success).to eq(1)
    #   expect(result.error).to eq(0)
    #   expect(result.duplicate).to eq(0)
    #   expect(MentionableItem.all.size).to eq(1)
    # end

 #   sheets.spreadsheet.get_spreadsheet_values(SiteSetting.mentionables_google_spreadsheet_id, "Sheet1!A1:H#{SiteSetting.mentionables_google_worksheet_max_row}").values
 

  # end

  # after(:all) do
  #   @session.spreadsheets.each do |sheet|
  #     sheet.delete(true)
  #   end
  # end

  # def create_spreadsheet(filename)
  #   @session.upload_from_file("#{FIXTURE_PATH}/#{filename}.csv", "Test: #{filename}")
  # end

  # it "Importing an empty sheet does nothing" do
  #   spreadsheet = create_spreadsheet("empty")
  #   result = described_class.new(spreadsheet).import

  #   expect(result.success).to eq(0)
  #   expect(result.error).to eq(0)
  #   expect(result.duplicate).to eq(0)
  #   expect(MentionableItem.all.size).to eq(0)
  # end


end
