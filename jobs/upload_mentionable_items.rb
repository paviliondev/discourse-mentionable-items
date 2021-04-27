# frozen_string_literal: true

module Jobs
  class UploadMentionableItems < ::Jobs::Scheduled
    every 2.hours

    def execute(args={})
      source = MentionableItems::GoogleSheets.new
      source.import
    end
  end
end
