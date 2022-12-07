# frozen_string_literal: true
require_relative '../../plugin_helper'
# require 'rspec-mocks'

describe ::Mentionables::GoogleSheets do
  FIXTURE_PATH = "#{Rails.root}/plugins/discourse-mentionables/spec/fixtures"

  before(:all) do
    # WebMock.allow_net_connect!
    SiteSetting.mentionables_onebox_fallback = false
    # @session = GoogleDrive::Session.from_service_account_key("#{FIXTURE_PATH}/google_sheets/service-account.json")
    # allow(Mentionables::GoogleAuthorization).to 
    # receive(:authorizer).and_return({})
    # stub.any_instance_of(sheep = mock('sheep').responds_like_instance_of(Sheep)).authorizer {
      # Google::Auth::ServiceAccountCredentials.new
    # }
    # expect(Mentionables::GoogleAuthorization).to receive(:authorizer)
    # byebug

    # auth = double("auth")
    # auth = instance_double("Mentionables::GoogleAuthorization", :authorizer => {})
     
    # Mentionables::GoogleAuthorization.stubs(:blah).and_return({})
    # Mentionables::GoogleAuthorization.expects(:authorizer).returns(Google::Auth::ServiceAccountCredentials.new)
    
    # stub.any_instance_of(Mentionables::GoogleAuthorization.authorizer).
  end
  context "spreadsheet has required columns" do
    before do
    
      # stub.any_instance_of(Google::Apis::SheetsV4::SheetsService).get_spreadsheet_values {
      #   [["name", "url", "description", "affiliate_snippet_1"],
      #   ["Tomato", "https://example.com/tomato", "A Tomato", "<div>Tomato</div>"],
      #   ["Orange", "https://example.com/tomato", "An Orange", "<div>Orange</div>"],
      #   ["Cucumber", "https://example.com/tomato", "A Cucumber", "<div>Cucumber</div>"]]
      #   }
    end

    it "Importing a sheet with required columns works" do

      SiteSetting.mentionables_google_spreadsheet_id = "3"
      Mentionables::GoogleAuthorization.stubs(:authorizer).returns(Google::Auth::ServiceAccountCredentials.new)
      # auth = mock('auth').responds_like(Mentionables::GoogleAuthorization)
      # auth.stubs(:authorizer).returns(Google::Auth::ServiceAccountCredentials.new)
      # sheet_service = mock('sheet_service').responds_like_instance_of(Google::Apis::SheetsV4::SheetsService)
      # sheet_service.stubs(:get_spreadsheet_values).returns{
      Google::Apis::SheetsV4::SheetsService.any_instance.stubs(:get_spreadsheet_values).returns({:values =>
        [["name", "url", "description", "affiliate_snippet_1"],
        ["Tomato", "https://example.com/tomato", "A Tomato", "<div>Tomato</div>"],
        ["Orange", "https://example.com/tomato", "An Orange", "<div>Orange</div>"],
        ["Cucumber", "https://example.com/tomato", "A Cucumber", "<div>Cucumber</div>"]]
    })

      #  stub.any_instance_of(Mentionables::GoogleAuthorization).authorizer {
      #   Google::Auth::ServiceAccountCredentials.new
      #  }
      # stub.any_instance_of(Google::Apis::SheetsV4::SheetsService).get_spreadsheet_values {
      #    [["name", "url", "description", "affiliate_snippet_1"],
      #    ["Tomato", "https://example.com/tomato", "A Tomato", "<div>Tomato</div>"],
      #    ["Orange", "https://example.com/tomato", "An Orange", "<div>Orange</div>"],
      #    ["Cucumber", "https://example.com/tomato", "A Cucumber", "<div>Cucumber</div>"]]
      #    }
      byebug
      workbook = ::Mentionables::GoogleSheets.new
      workbook.request_spreadsheet
      result = workbook.import
      # result = described_class.new(spreadsheet).import
  
      expect(result.success).to eq(1)
      expect(result.error).to eq(0)
      expect(result.duplicate).to eq(0)
      expect(MentionableItem.all.size).to eq(3)
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
