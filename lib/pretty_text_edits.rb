# frozen_string_literal: true

module PrettyText
  module Helpers
    extend self

    # TAG_HASHTAG_POSTFIX = "::tag"

    def mentionable_item_lookup(text)
      is_mentionable_item = text =~ /\+[^ |\n]*/

      if (is_mentionable_item && mentionable_item = MentionableItem.find_by(url: "https://#{text[1..]}"))
        [mentionable_item.url, mentionable_item.name]
      else
        nil
      end
    end
  end
end