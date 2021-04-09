# frozen_string_literal: true

module Jobs
  # UploadMentionableItems Job uploads configured spreadsheet data
  class UploadMentionableItems < ::Jobs::Scheduled
    every 2.hours

    def execute(args={})
      ::MentionableItems::GoogleSheetOperations.ingest_sheet
    end
  end
end
