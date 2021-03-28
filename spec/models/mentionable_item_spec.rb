# frozen_string_literal: true
require_relative '../plugin_helper'

describe MentionableItem do
  empty_item = {}
  a_sparse_item = {url: 'https://news.bbc.co.uk'}
  a_duplicate_sparse_item = {url: 'https://news.bbc.co.uk'}
  an_item_without_an_image = {url: 'https://cnn.com'}

  MentionableItem.add!(a_sparse_item)

  it "Adding an empty item results in failure" do
    expect(MentionableItem.add!(empty_item)).to eq(0)
  end
  it "Adding an item where the url already exists results in failure" do
    expect(MentionableItem.add!(a_sparse_item)).to eq(0)
  end
  
  it "Adding an item where the url has just been removed succeeds" do
    MentionableItem.add!(a_sparse_item)
    MentionableItem.remove!(a_sparse_item)
    expect(MentionableItem.add!(a_duplicate_sparse_item)).to eq(1)
  end
  
end
