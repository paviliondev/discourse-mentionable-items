# frozen_string_literal: true
require_relative '../../plugin_helper'

describe ::Mentionables::GoogleSheets do
  FIXTURE_PATH = "#{Rails.root}/plugins/discourse-mentionables/spec/fixtures"

  before(:all) do
    WebMock.allow_net_connect!
    SiteSetting.mentionables_onebox_fallback = false
    @session = GoogleDrive::Session.from_service_account_key("#{FIXTURE_PATH}/google_sheets/service-account.json")
  end

  after(:all) do
    @session.spreadsheets.each do |sheet|
      sheet.delete(true)
    end
  end

  def create_spreadsheet(filename)
    @session.upload_from_file("#{FIXTURE_PATH}/#{filename}.csv", "Test: #{filename}")
  end

  it "Importing an empty sheet does nothing" do
    spreadsheet = create_spreadsheet("empty")
    result = described_class.new(spreadsheet).import

    expect(result.success).to eq(0)
    expect(result.error).to eq(0)
    expect(result.duplicate).to eq(0)
    expect(MentionableItem.all.size).to eq(0)
  end

  it "Importing a sheet with required columns works" do
    spreadsheet = create_spreadsheet("required_only")
    result = described_class.new(spreadsheet).import

    expect(result.success).to eq(1)
    expect(result.error).to eq(0)
    expect(result.duplicate).to eq(0)
    expect(MentionableItem.all.size).to eq(1)
  end

  it "Importing a sheet with optional columns works" do
    spreadsheet = create_spreadsheet("required_and_optional")
    result = described_class.new(spreadsheet).import

    expect(result.success).to eq(1)
    expect(result.error).to eq(0)
    expect(result.duplicate).to eq(0)
    expect(MentionableItem.all.size).to eq(1)
  end
end
