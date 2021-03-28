module ::MentionableItems
  class Engine < ::Rails::Engine
    engine_name 'mentionable_items'
    isolate_namespace MentionableItems
  end
  PLUGIN_NAME ||= 'mentionable_items'
end