module ::Mentionables
  PLUGIN_NAME ||= 'mentionables'

  class Engine < ::Rails::Engine
    engine_name PLUGIN_NAME
    isolate_namespace Mentionables
  end

  def self.info
    Hash[
      total: MentionableItem.all.size
    ]
  end
end