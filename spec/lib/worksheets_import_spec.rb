# frozen_string_literal: true
require_relative '../plugin_helper'

describe ::MentionableItems::WorksheetsImport do
  empty_worksheet = [["",""], ["",""]]
  worsheet_with_url = [["url",""], ["https:\\news.bbc.co.uk",""]]

  # it "Importing an empty sheet results in no records" do
  #   result = ::MentionableItems::WorksheetsImport.import_sheet(empty_worksheet)
  #   expect(result[:success_rows]).to eq(0)
  # end

  it "Importing a sheet with a valid url results in one successful import" do
    result = ::MentionableItems::WorksheetsImport.import_sheet(worsheet_with_url)
    expect(result[:success_rows]).to eq(1)
  end
end
