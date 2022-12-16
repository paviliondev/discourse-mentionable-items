# frozen_string_literal: true
require_relative '../../plugin_helper'
# require 'rspec-mocks'

describe ::Mentionables::GoogleSheets do
  FIXTURE_PATH = "#{Rails.root}/plugins/discourse-mentionables/spec/fixtures"

  context "spreadsheet has required columns" do
    it "Importing a sheet with required columns works" do
      SiteSetting.mentionables_google_spreadsheet_id = "invented"
      SiteSetting.mentionables_onebox_fallback = true
      Mentionables::GoogleAuthorization.stubs(:authorizer).returns(Google::Auth::ServiceAccountCredentials.new)
      Oneboxer.stubs(:preview).returns("<aside class=\"onebox allowlistedgeneric\" data-onebox-src=\"https://example.com/comm-link/transmission/Roadmap-Roundup\">\n  <header class=\"source\">\n\n      <a href=\"https://example.com/comm-link/transmission/Roadmap-Roundup\" target=\"_blank\" rel=\"nofollow ugc noopener\">Roadmap Roundup</a>\n  </header>\n\n  <article class=\"onebox-body\">\n    <img src=\"https://example.com/media/qoxio5lo5vxv3r/channel_item_full/ROADMAPBANNER.jpg\" class=\"thumbnail\">\n\n<h3><a href=\"https://example.com/comm-link/transmission/Roadmap-Roundup\" target=\"_blank\" rel=\"nofollow ugc noopener\">Roadmap Roundup</a></h3>\n\n  <p>Example is the official go-to website for all news  about roadmap stuff.</p>\n\n\n  </article>\n\n  <div class=\"onebox-metadata\">\n    \n    \n  </div>\n\n  <div style=\"clear: both\"></div>\n</aside>\n")
      Google::Apis::SheetsV4::SheetsService.any_instance.stubs(:get_spreadsheet_values).returns(stub('values',
        values: [["url"],
        ["https://example.com/tomato"]]
      ))

      workbook = ::Mentionables::GoogleSheets.new
      workbook.request_spreadsheet
      result = workbook.import

      expect(result.success).to eq(1)
      expect(result.error).to eq(0)
      expect(result.duplicate).to eq(0)
      expect(MentionableItem.all.size).to eq(1)
    end
  end

  context "spreadsheet has optional columns" do
    it "Importing a sheet with optional columns works" do
      SiteSetting.mentionables_google_spreadsheet_id = "invented"
      SiteSetting.mentionables_onebox_fallback = false
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
      SiteSetting.mentionables_onebox_fallback = false
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
end
