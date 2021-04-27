module ::MentionableItems
  PLUGIN_NAME ||= 'mentionable_items'

  class Engine < ::Rails::Engine
    engine_name PLUGIN_NAME
    isolate_namespace MentionableItems
  end
end