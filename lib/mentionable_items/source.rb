# frozen_string_literal: true

class ::MentionableItems::Source
  REQUIRED_KEYS ||= %w(
    name
    url
  )
  OPTIONAL_KEYS ||= %w(
    slug
    image_url
    description
    affiliate_snippet_1
    affiliate_snippet_2
    affiliate_snippet_3
  )
  KEYS ||= REQUIRED_KEYS + OPTIONAL_KEYS

  attr_accessor :ready

  def initialize(items = nil)
  end

  def ready?
    @ready ||= false
  end

  def import
    if !ready?
      MentionableItems::Log.create(
        type: MentionableItems::Log.types[:warn],
        source: source_name,
        message: I18nt.t('mentionable_items.log.message.import_did_not_start')
      )
      return nil
    end

    @result = MentionableItems::ImportResult.new

    import_from_source

    if @result.error?
      log_type = MentionableItems::Log.types[:error]
      message = @result.error
    else
      log_type = MentionableItems::Log.types[:report]
      message = @result.report
    end

    MentionableItems::Log.create(
      type: log_type,
      source: source_name,
      message: message
    )

    @result
  end
  
  protected

  def source_name
    # to be overridden by child class
  end

  def import_from_source
    # to be overridden by child class
  end

  def validate_item
    # must be used by child class in import_from_source prior to creating an item
  end
end