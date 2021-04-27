# frozen_string_literal: true
require_relative '../plugin_helper'

describe ::MentionableItems::GoogleSheets do
  empty_worksheet = [["",""], ["",""]]
  worsheet_with_url = [["url",""], ["https:\\news.bbc.co.uk",""]]
  worsheet_with_url_and_name = [["url","", "name"], ["https:\\linkin.com","","Meghan"], ["https:\\news.bbc.co.uk","","Harry"]]

  it "Importing an empty sheet results in no records" do
    result = described_class.import_sheet(empty_worksheet)
    expect(result[:success_rows]).to eq(0)
  end

  it "Importing a sheet with a valid url results in one successful import" do
    result = described_class.import_sheet(worsheet_with_url)
    expect(result[:success_rows]).to eq(1)
  end

  it "Importing a sheet with a valid url results in one successful import" do
    result = described_class.import_sheet(worsheet_with_url_and_name)
    expect(MentionableItem.where(name: "Harry").count).to eq(1)
  end
end
