module ::MentionableItems
  PLUGIN_NAME ||= 'mentionable_items'

  class Engine < ::Rails::Engine
    engine_name PLUGIN_NAME
    isolate_namespace MentionableItems
  end

  def self.info
    Hash[
      total: MentionableItem.all.size
    ]
  end
end