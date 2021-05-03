class MentionableItems::Log
  include ActiveModel::Serialization

  attr_accessor :type,
                :source,
                :message,
                :date

  PAGE_LIMIT = 100
  
  def initialize(attrs)
    attrs = attrs.with_indifferent_access

    @type = attrs[:type]
    @source = attrs[:source]
    @message = attrs[:message]
  end

  def self.types
    @types ||= Enum.new(
      info: 1,
      report: 2,
      warning: 3,
      error: 4
    )
  end

  def self.create(opts)
    log_id = SecureRandom.hex(8)

    PluginStore.set(
      MentionableItems::PLUGIN_NAME,
      "log_#{log_id}",
      opts.merge(date: Time.now)
    )
  end

  def self.list_query
    PluginStoreRow.where("
      plugin_name = '#{MentionableItems::PLUGIN_NAME}' AND
      key LIKE 'log_%' AND
      (value::json->'date') IS NOT NULL
    ").order("value::json->>'date' DESC")
  end

  def self.list(page: 0, filter: '')
    list = list_query

    if filter
      list = list.where("
        value::json->>'source' ~ '#{filter}' OR
        value::json->>'message' ~ '#{filter}'
      ")
    end

    list.limit(PAGE_LIMIT)
      .offset(page * PAGE_LIMIT)
      .map do |r|
        data = JSON.parse(r.value)
        log = self.new(data)
        log.date = data['date']
        log
      end
  end
end