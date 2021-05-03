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
        type: MentionableItems::Log.types[:warning],
        source: source_name,
        message: I18n.t('mentionable_items.import_did_not_start')
      )
      return nil
    end

    @result = MentionableItems::ImportResult.new

    items = get_items_from_source
    @result.total = items.size

    items.each do |item|
      item = validate_item_hash(item)
      next unless item

      create_result = false
      invalid_record = false
      begin
        create_result = MentionableItem.create!(item)
      rescue ActiveRecord::RecordInvalid
        invalid_record = true
      end

      if create_result
        @result.success += 1
      else
        if invalid_record
          @result.duplicate += 1
        else
          @result.failed_to_create += 1
        end
      end
    end

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

  def get_items_from_source
    # to be overridden by child class. Should return an array of hashes.
  end

  def validate_item_hash(item)
    item = item.delete_if { |k, v| v.empty? }

    if REQUIRED_KEYS.any? { |key| !item.has_key?(key.to_sym) }
      @result.missing_required += 1
      item_identifier = find_first_required_value(item)
      @result.missing_required_items << item_identifier if item_identifier.present?
      return false
    end

    if (item[:url] =~ URI::regexp).nil?
      @result.invalid_format += 1
      item_identifier = find_first_required_value(item)
      @result.invalid_format_items << item_identifier if item_identifier.present?
      return false
    end

    return item
  end

  def find_first_required_value(item)
    value = nil

    REQUIRED_KEYS.each do |key|
      if item[key.to_sym].present?
        value = item[key.to_sym]
      end
    end

    value
  end
end