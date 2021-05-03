class MentionableItems::LogSerializer < ::ApplicationSerializer
  attributes :type,
             :source,
             :message,
             :date

  def type
    MentionableItems::Log.types.key(object.type).to_s
  end
end