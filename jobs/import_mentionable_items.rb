# frozen_string_literal: true

module Jobs
  class ImportMentionableItems < ::Jobs::Base
    def execute(args={})
      source_name = SiteSetting.mentionables_source.to_s
      klass = "Mentionables::#{source_name.camelize}".constantize

      if klass&.respond_to?(:new)
        source = klass.new
        source.import
      end
    end
  end
end
