# frozen_string_literal: true

class ::MentionableItems::ImportResult
  attr_accessor :total,
                :successful,
                :failed,
                :duplicates

  def initialize
    @total = 0
    @failed = 0
    @successful = 0
    @duplicates = 0
  end

  def report
    I18n.t("mentionable_items.report",
      total: total,
      successful: successful,
      failed: failed,
      duplicates: duplicates
    )
  end
end