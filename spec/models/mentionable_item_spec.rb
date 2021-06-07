# frozen_string_literal: true
require_relative '../plugin_helper'

describe MentionableItem do
  FIXTURE_PATH = "#{Rails.root}/plugins/discourse-mentionable-items/spec/fixtures"

  before do
    CSV.foreach("#{FIXTURE_PATH}/required_only.csv", headers: true) do |row|
      @required_item = row.to_h
    end
    CSV.foreach("#{FIXTURE_PATH}/required_and_optional.csv", headers: true) do |row|
      @required_and_optional_item = row.to_h
    end
  end

  it "adds missing slug if mentionables_generate_slugs is true" do
    mentionable_item = described_class.new(@required_item)
    mentionable_item.save
    expect(mentionable_item.reload.slug).to eq('bbc')
  end

  it "does not validate if missing slug and mentionables_generate_slugs is false" do
    SiteSetting.mentionables_generate_slugs = false
    mentionable_item = described_class.new(@required_item)
    expect(mentionable_item).to_not be_valid
  end

  it "allows user to provide slug" do
    SiteSetting.mentionables_generate_slugs = false
    mentionable_item = described_class.new(@required_and_optional_item)
    mentionable_item.save
    expect(mentionable_item.reload.slug).to eq('bbc-news')
  end
end
