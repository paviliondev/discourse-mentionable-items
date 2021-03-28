# frozen_string_literal: true

module Jobs
  # UploadMentionableItemss Job uploads configured spreadsheet data
  class UploadMentionableItemss < ::Jobs::Scheduled
    every 2.hours

    def execute(args={})
      ::MentionableItems::GoogleSheetOperations.ingest_sheet
    end
  end
end
