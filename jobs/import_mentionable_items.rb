# frozen_string_literal: true

module Jobs
  class ImportMentionableItems < ::Jobs::Scheduled
    every 2.hours

    def execute(args={})
      source = MentionableItems::GoogleSheets.new
      source.import if source.ready?
    end
  end
end
