# frozen_string_literal: true

module Jobs
  class DestroyMentionableItems < ::Jobs::Base
    def execute(args = {})
      MentionableItem.destroy_all
    end
  end
end
