
class ::MentionableItems::Source
  REQUIRED_KEYS ||= %w(
    url
    name
  )
  OPTIONAL_KEYS ||= %w(
    image_url
    description
    affiliate_snippet_1
    affiliate_snippet_2
    affiliate_snippet_3
  )

  attr_reader :keys

  def initialize(items = nil)
    @keys = REQUIRED_KEYS + OPTIONAL_KEYS
  end

  def import
    @result = MentionableItems::ImportResult.new
    import_from_source
    Rails.logger.info(@result.report)
    @result
  end

  def import_from_source
    # to be overridden by parent class
  end
end