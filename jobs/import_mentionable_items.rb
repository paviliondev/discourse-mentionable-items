# frozen_string_literal: true

module Jobs
  class ImportMentionableItems < ::Jobs::Scheduled
    every 2.hours

    def execute(args={})
      source_name = SiteSetting.mentionable_items_source.to_s
      klass = "MentionableItems::#{source_name.camelize}".constantize

      if klass&.respond_to?(:new)
        source = klass.new
        source.import
      end
    end
  end
end
